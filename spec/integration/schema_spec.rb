# encoding: utf-8

require 'spec_helper'

require 'dm-core'
require 'dm-migrations'

require 'axiom'
require 'axiom-do-adapter'

require 'ramom'
require 'ramom/relation/builder/dm'
require 'ramom/schema/definition/builder/dm'

describe Ramom do

  # (1) Setup and define tables with DataMapper

  uri = 'postgres://localhost/test'.freeze

  DataMapper.logger = DataMapper::Logger.new($stdout, :debug) if ::ENV['LOG']
  adapter = DataMapper.setup(:default, uri)
  adapter.field_naming_convention = DataMapper::NamingConventions::Field::FQN

  class Account
    include DataMapper::Resource

    property :id,    Serial
    property :email, String, unique: true
  end

  class Person
    include DataMapper::Resource

    property :id,         Serial
    property :name,       String, unique_index: :test_compound_index
    property :nickname,   String, unique_index: :test_compound_index
    property :account_id, Integer, field: 'account_id'

    belongs_to :account
    has n, :tasks
  end

  class Task
    include DataMapper::Resource

    property :id,        Serial
    property :name,      String
    property :person_id, Integer, field: 'person_id'

    belongs_to :person
  end

  DataMapper.finalize.auto_migrate!

  Person.create(
    name:     'snusnu',
    nickname: 'gams',
    account:  { email: 'test@test.com' },
    tasks:    [{name: 'test'}]
  )

  # (2) Initialize a new Ramom::Schema

  models          = DataMapper::Model.descendants
  base_relations  = Ramom::Schema::Definition::Builder::DM.call(models)

  schema_definition = Ramom::Schema.define(base_relations) do

    external :actors do |account_id|
      people.
        join(accounts.restrict(account_id: account_id)).
        wrap(account: [:account_id, :account_email])
    end

    external :person_details do |account_id|
      task_actors(account_id).
        group(tasks: [:task_id, :task_name])
    end

    external :task_details do |account_id|
      task_actors(account_id).
        wrap(person: [:person_id, :person_name, :account])
    end

    internal :task_actors do |account_id|
      tasks.join(actors(account_id))
    end

  end

  # (3) Define domain DTOs

  entity_registry = Ramom::Entity::Definition::Registry.build(guard: false) do

    register :account do
      map :id,    from: :account_id
      map :email, from: :account_email
    end

    register :person do
      map :id,         from: :person_id
      map :account_id, from: :account_id
      map :name,       from: :person_name
    end

    register :task do
      map :id,   from: :task_id
      map :name, from: :task_name
    end

    register :detailed_person do
      map :id,   from: :person_id
      map :name, from: :person_name

      wrap :account, entity: :'detailed_person.account' do
        map :id,    from: :account_id
        map :email, from: :account_email
      end

      group :tasks, entity: :'detailed_person.task' do
        map :id,   from: :task_id
        map :name, from: :task_name
      end
    end

    register :detailed_task do
      map :id,   from: :task_id
      map :name, from: :task_name

      wrap :person, entity: :'task.person' do
        map :id,   from: :person_id
        map :name, from: :person_name

        wrap :account, entity: :'task.person.account' do
          map :id,    from: :account_id
          map :email, from: :account_email
        end
      end
    end

    register :actor do
      map :id,   from: :person_id
      map :name, from: :person_name

      wrap :account, entity: :'actor.account' do
        map :id,    from: :account_id
        map :email, from: :account_email
      end
    end

  end

  models   = entity_registry.models(:anima)
  entities = entity_registry.environment(models)

  # (4) Connect schema relations with DTO mappers

  mapping = Ramom::Mapping.new(entities) do
    map :accounts,       :account
    map :people,         :person
    map :tasks,          :task
    map :person_details, :detailed_person
    map :task_details,   :detailed_task
    map :actors,         :actor
  end

  # (5) Connect the relation schema to a database

  adapter = Axiom::Adapter::DataObjects.new(uri)

  let(:db) { Ramom::Reader.build(adapter, schema_definition, mapping) }

  let(:account) { db.one(:accounts) }
  let(:person)  { db.one(:people) }
  let(:task)    { db.one(:tasks) }

  it 'provides access to base relations' do
    expect(account.id).to_not be(nil)
    expect(account.email).to eq('test@test.com')

    expect(person.id).to_not be(nil)
    expect(person.name).to eq('snusnu')
    expect(person.account_id).to eql(account.id)

    expect(db.read(:accounts).sort.one).to eql(account)
    expect(db.read(:people).sort.one).to eql(person)
  end

  it 'provides access to virtual relations' do
    a = db.one(:actors, 1)
    expect(a.id).to eq(person.id)
    expect(a.name).to eq(person.name)
    expect(a.account.id).to eq(account.id)
    expect(a.account.email).to eq(account.email)

    dt = db.one(:task_details, 1)
    expect(dt.id).to eq(task.id)
    expect(dt.name).to eq(task.name)
    expect(dt.person.id).to eq(person.id)
    expect(dt.person.name).to eq(person.name)
    expect(dt.person.account.id).to eql(account.id)
    expect(dt.person.account.email).to eql(account.email)

    dp = db.one(:person_details, 1)
    expect(dp.id).to eq(person.id)
    expect(dp.name).to eq(person.name)
    expect(dp.account.id).to eq(account.id)
    expect(dp.account.email).to eq(account.email)

    t = dp.tasks.first
    expect(t.id).to eq(task.id)
    expect(t.name).to eq(task.name)

    tuple  = db.schema.actors(1).sort.one
    mapper = db.mapping[:actors]

    expect(mapper.load(tuple)).to eql(a)

    expect {
      db.schema.task_actors(1).one
    }.to raise_error(NoMethodError)
  end
end
