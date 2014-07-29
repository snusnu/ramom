# encoding: utf-8

require 'spec_helper'

require 'dm-core'
require 'dm-migrations'

require 'mom'

require 'ramom'
require 'ramom/relation/builder/dm'
require 'ramom/schema/definition/builder/dm'
require 'ramom/writer/dm'

require 'axiom-do-adapter'

ENV['TZ'] = 'UTC'     # VERY IMPORTANT
Axiom::Types.finalize # VERY IMPORTANT

# (1) Setup and define tables with DataMapper

uri = 'postgres://localhost/test'.freeze

DataMapper.logger = DataMapper::Logger.new($stdout, :debug) if ::ENV['LOG']
DataMapper.setup(:default, uri)

class Company
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, required: true
end

class Person
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, required: true
end

class Employment
  include DataMapper::Resource

  property :id, Serial

  belongs_to :company
  belongs_to :person
end

class Event
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, required: true
  property :created_at, DateTime, required: true

  belongs_to :company
end

class Instruction
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, required: true
  property :date, Date,   required: true

  belongs_to :employment
end

DataMapper.finalize.auto_migrate!

company_1    = Company.create(name: 'company 1')
company_2    = Company.create(name: 'company 2')
person_1     = Person.create(name: 'person 1')
person_2     = Person.create(name: 'person 2')
employment_1 = Employment.create(company: company_1, person: person_1)
employment_2 = Employment.create(company: company_2, person: person_2)

3.times do |i|
  Event.create(
    name:       "event #{i+1}",
    created_at: DateTime.new(2014, 7, i+1),
    company:    company_1
  )
end

Event.create(
  name:       "event 4",
  created_at: DateTime.new(2014, 7, 4),
  company:    company_2
)

3.times do |i|
  Instruction.create(
    name:       "instruction #{i+1}",
    date:       DateTime.new(2014, 7, i+1),
    employment: employment_1
  )
end

Instruction.create(
  name:       "instruction 4",
  date:       DateTime.new(2014, 7, 4),
  employment: employment_2
)

puts

# (2) Initialize a new Ramom::Schema

models        = DataMapper::Model.descendants
dm_definition = Ramom::Schema::Definition::Builder::DM.call(models)

options = {
  base:           dm_definition[:base_relations],
  fk_constraints: dm_definition[:fk_constraints]
}

schema_definition = Ramom::Schema.define(options) do

  external :dashboard do |company_id, employment_id|
    rel = employee(employment_id).
      join(people).
      join(companies).
      join(page(instructions, [:instruction_date], 2, 2)).
      join(page(events,       [:event_created_at], 2, 2)).
      wrap(person: people.header.map(&:name)).
      group(
        events:       events.header.map(&:name),
        instructions: instructions.header.map(&:name),
      )

    add_page_info(rel, {
      instructions_page: {
        number: 2,
        limit:  2,
        rel: employment_instructions(employment_id)
      },
      events_page: {
        number: 2,
        limit:  2,
        rel: company_events(company_id)
      },
    })
  end

  internal :employee do |employment_id|
    employments.restrict(employment_id: employment_id)
  end

  internal :company_events do |company_id|
    companies.restrict(company_id: company_id).join(events)
  end

  internal :employment_instructions do |employment_id|
    employments.restrict(employment_id: employment_id).join(instructions)
  end

end

options  = Ramom::Schema::Mapping.default_options(schema_definition)
dressers = Mom::Definition::Registry.build(options) do

  register :page_info do
    map :number, from: :number
    map :limit , from: :limit
    map :total , from: :total
  end

  register :dashboard do
    wrap :person do
      map :id
      map :name
    end

    wrap :events_page,       entity: :page_info
    wrap :instructions_page, entity: :page_info

    group :events do
      map :id
      map :name
      map :created_at
    end

    group :instructions do
      map :id
      map :name
      map :date
    end
  end
end

# This mutates +dressers+ and adds base relation mappers
Ramom::EntityBuilder.call(schema_definition, dressers) #, [
#
# Passing a whitelist of base relation names to generate
# mappers from is also supported. If no relation names
# are given, mappers for all base relations are generated.
#
# This is useful for automatically generating mappers
# that are used for mapping base relation tuples that
# get returned from successful write operations. Most
# of the time, not all base relations need respective
# mappers.
#
#  :people,
#  :employments,
#])

INPUT_DRESSERS  = {} # TODO add some
OUTPUT_DRESSERS = Mom.object_mappers(dressers)

adapter  = Axiom::Adapter::DataObjects.new(uri)
schema   = Ramom::Schema.build(adapter, schema_definition)
writer   = Ramom::Writer::DM.build(DataMapper::Model.descendants)
database = Ramom::Database.new(schema, writer)

OP_ENV = Ramom::Operation::Environment.new(database: database)

class C
  include Ramom.command(INPUT_DRESSERS, OP_ENV, self)
end

class Q
  include Ramom.query(OUTPUT_DRESSERS, OP_ENV, self)
end

Q.register :people, dresser: :person do
  read(rel(:people))
end

Q.register :dashboard, dresser: :dashboard do |params|
  one(rel(:dashboard, params[:company_id], params[:employment_id]))
end

describe 'ramom' do
  let(:db) { Ramom::Facade.build(C, Q) }

  it 'does allow to call external relations directly' do
    expect { schema.dashboard(1, 1) }.to_not raise_error
  end

  it 'does not allow to call internal relations directly' do
    expect { schema.employee(1) }.to raise_error(NoMethodError)
  end

  it 'supports reading dressed base relations' do
    db.read(:people).each_with_index do |person, i|
      expect(person.id).to_not be(nil)
      expect(person.name).to eq("person #{i+1}")
    end
  end

  it 'supports reading dressed virtual relations' do
    d = db.read(:dashboard, company_id: 1, employment_id: 1)

    expect(d.person.id).to_not be(nil)
    expect(d.person.name).to eq('person 1')

    expect(d.events_page.number).to be(2)
    expect(d.events_page.limit).to be(2)
    expect(d.events_page.total).to be(3)

    expect(d.instructions_page.number).to be(2)
    expect(d.instructions_page.limit).to be(2)
    expect(d.instructions_page.total).to be(3)

    expect(d.events.size).to be(1)

    expect(d.events.first.id).to_not be(nil)
    expect(d.events.first.name).to eq("event 3")
    expect(d.events.first.created_at).to eq(DateTime.new(2014, 7, 3))

    expect(d.instructions.size).to be(1)

    expect(d.instructions.first.id).to_not be(nil)
    expect(d.instructions.first.name).to eq("instruction 3")
    expect(d.instructions.first.date).to eq(DateTime.new(2014, 7, 3))
  end
end
