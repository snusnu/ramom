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

company    = Company.create(name: 'test')
person     = Person.create(name: 'snusnu')
employment = Employment.create(company: company, person: person)

3.times do |i|
  Event.create(
    name:       "event #{i+1}",
    created_at: DateTime.new(2014, 7, i+1),
    company:    company
  )
end

3.times do |i|
  Instruction.create(
    name:       "instruction #{i+1}",
    date:       DateTime.new(2014, 7, i+1),
    employment: employment
  )
end

puts

# (2) Initialize a new Ramom::Schema

models        = DataMapper::Model.descendants
dm_definition = Ramom::Schema::Definition::Builder::DM.call(models)

options = {
  base:           dm_definition[:base_relations],
  fk_constraints: dm_definition[:fk_constraints]
}

schema_definition = Ramom::Schema.define(options) do

  external :dashboard do |employment_id|
    rel = employee(employment_id).
      join(people).
      join(page(instructions, [:instruction_date], 1, 2)).
      join(page(events,       [:event_created_at], 1, 2)).
      wrap(person: people.header.map(&:name)).
      group(
        events:       events.header.map(&:name),
        instructions: instructions.header.map(&:name),
      )

    add_page_info(rel, {
      instructions_page: {number: 1, limit: 2, rel: instructions},
      events_page:       {number: 1, limit: 2, rel: events},
    })
  end

  internal :employee do |employment_id|
    employments.restrict(employment_id: employment_id)
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

# This mutates +definition_registry+ and adds base relation mappers
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

class C < Ramom::Command
  include Ramom::Operation::Registrar.build(INPUT_DRESSERS)
end

class Q < Ramom::Query
  include Ramom::Operation::Registrar.build(OUTPUT_DRESSERS)
end

class ListPeople < Q
  register :people, dresser: :person

  def call
    read(rel(:people))
  end
end

class ShowDashboard < Q
  register :dashboard, dresser: :dashboard

  def call(params)
    one(rel(:dashboard, params[:employment_id]))
  end
end

adapter     = Axiom::Adapter::DataObjects.new(uri)
schema      = Ramom::Schema.build(adapter, schema_definition)
writer      = Ramom::Writer::DM.build(DataMapper::Model.descendants)
database    = Ramom::Database.new(schema, writer)
environment = Ramom::Operation::Environment.new(database: database)

describe 'ramom' do
  let(:db) { Ramom::Facade.new(C.registry, Q.registry, environment) }

  it 'does allow to call external relations directly' do
    expect {
      schema.dashboard(1)
    }.to_not raise_error(NoMethodError)
  end

  it 'does not allow to call internal relations directly' do
    expect {
      schema.employee(1)
    }.to raise_error(NoMethodError)
  end

  it 'supports reading dressed base relations' do
    person = db.read(:people).one

    expect(person.id).to_not be(nil)
    expect(person.name).to eq('snusnu')
  end

  it 'supports reading dressed virtual relations' do
    d = db.read(:dashboard, employment_id: 1)

    expect(d.person.id).to_not be(nil)
    expect(d.person.name).to eq('snusnu')

    expect(d.events_page.number).to be(1)
    expect(d.events_page.limit).to be(2)
    expect(d.events_page.total).to be(3)

    expect(d.instructions_page.number).to be(1)
    expect(d.instructions_page.limit).to be(2)
    expect(d.instructions_page.total).to be(3)

    expect(d.events.size).to be(2)

    d.events.each_with_index do |event, i|
      expect(event.id).to_not be(nil)
      expect(event.name).to eq("event #{i+1}")
      expect(event.created_at).to eq(DateTime.new(2014, 7, i+1))
    end

    expect(d.instructions.size).to be(2)

    d.instructions.each_with_index do |instruction, i|
      expect(instruction.id).to_not be(nil)
      expect(instruction.name).to eq("instruction #{i+1}")
      expect(instruction.date).to eq(DateTime.new(2014, 7, i+1))
    end
  end
end
