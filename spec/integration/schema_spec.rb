# encoding: utf-8

require 'spec_helper'

require 'dm-core'
require 'dm-migrations'

require 'axiom'
require 'axiom-do-adapter'

require 'ramom/entity'
require 'ramom/schema'

describe Ramom::Schema do

  # (1) Setup and define tables with DataMapper

  uri = 'postgres://localhost/test'.freeze

  DataMapper.logger = DataMapper::Logger.new($stdout, :debug) if ::ENV['LOG']
  adapter = DataMapper.setup(:default, uri)
  adapter.field_naming_convention = DataMapper::NamingConventions::Field::FQN

  class Account
    include DataMapper::Resource

    property :id,    Serial
    property :email, String
  end

  class Person
    include DataMapper::Resource

    property :id,         Serial
    property :name,       String
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
    name:    'snusnu',
    account: { email: 'test@test.com' },
    tasks:   [{name: 'test'}]
  )

  # (2) Initialize a new Ramom::Relation::Schema

  models          = DataMapper::Model.descendants
  base_relations  = Ramom::Relation::Schema::Definition::Builder::DM.call(models)

  schema_definition = Ramom::Relation::Schema.define(base_relations) do

    relation(:actors) do
      people.
        join(accounts).
        wrap(account: [:account_id, :account_email])
    end

    relation :person_details do
      actors.
        join(tasks).
        group(tasks: [:task_id, :task_name])
    end

    relation :task_details do
      tasks.
        join(actors).
        wrap(person: [:person_id, :person_name, :account])
    end

  end

  # (3) Connect the relation schema to a database

  adapter  = Axiom::Adapter::DataObjects.new(uri)
  database = Ramom::Database.build(:test, adapter, schema_definition)

  # (4) Define domain DTOs

  entity_registry = Ramom::Entity::Definition::Registry.build(guard: false) do

    register :account do
      map :id,    :Integer, from: :account_id
      map :email, :String,  from: :account_email
    end

    register :person do
      map :id,         :Integer, from: :person_id
      map :account_id, :Integer, from: :account_id
      map :name,       :String,  from: :person_name
    end

    register :task do
      map :id,   :Integer, from: :task_id
      map :name, :String,  from: :task_name
    end

    register :detailed_person do
      map :id,         :Integer, from: :person_id
      map :name,       :String,  from: :person_name

      wrap :account, entity: :'detailed_person.account' do
        map :id,    :Integer, from: :account_id
        map :email, :String,  from: :account_email
      end

      group :tasks, entity: :'detailed_person.task' do
        map :id,   :Integer, from: :task_id
        map :name, :String,  from: :task_name
      end
    end

    register :detailed_task do
      map :id,         :Integer, from: :task_id
      map :name,       :String,  from: :task_name

      wrap :person, entity: :'task.person' do
        map :id,   :Integer, from: :person_id
        map :name, :String,  from: :person_name

        wrap :account, entity: :'task.person.account' do
          map :id,    :Integer, from: :account_id
          map :email, :String,  from: :account_email
        end
      end
    end

    register :actor do
      map :id,         :Integer, from: :person_id
      map :name,       :String,  from: :person_name

      wrap :account, entity: :'actor.account' do
        map :id,       :Integer, from: :account_id
        map :email,    :String,  from: :account_email
      end
    end

  end

  models   = entity_registry.models(:anima)
  entities = entity_registry.environment(models)

  # (5) Connect schema relations with DTO mappers

  schema = Ramom::Schema.build(database, entities) do
    map :accounts,       :account
    map :people,         :person
    map :tasks,          :task
    map :person_details, :detailed_person
    map :task_details,   :detailed_task
    map :actors,         :actor
  end

  it 'provides access to base relations' do

    account = schema[:accounts].sort.one
    expect(account.id).to_not be(nil)
    expect(account.email).to eq('test@test.com')

    person = schema[:people].sort.one
    expect(person.id).to_not be(nil)
    expect(person.name).to eq('snusnu')
    expect(person.account_id).to eql(account.id)

    a = schema[:accounts].to_a.first
    expect(a.id).to_not be(nil)
    expect(a.email).to eq('test@test.com')

    p = schema[:people].to_a.first
    expect(p.id).to_not be(nil)
    expect(p.name).to eq('snusnu')
    expect(p.account_id).to eql(account.id)
  end

  it 'provides access to virtual relations' do
    account = schema[:accounts].sort.one
    person  = schema[:people].sort.one
    task    = schema[:tasks].sort.one

    a = schema[:actors].to_a.first
    expect(a.id).to eq(person.id)
    expect(a.name).to eq(person.name)
    expect(a.account.id).to eq(account.id)
    expect(a.account.email).to eq(account.email)

    dt = schema[:task_details].to_a.first
    expect(dt.id).to eq(task.id)
    expect(dt.name).to eq(task.name)
    expect(dt.person.id).to eq(person.id)
    expect(dt.person.name).to eq(person.name)
    expect(dt.person.account.id).to eql(account.id)
    expect(dt.person.account.email).to eql(account.email)

    dp = schema[:person_details].to_a.first
    expect(dp.id).to eq(person.id)
    expect(dp.name).to eq(person.name)
    expect(dp.account.id).to eq(account.id)
    expect(dp.account.email).to eq(account.email)

    t = dp.tasks.to_a.first
    expect(t.id).to eq(task.id)
    expect(t.name).to eq(task.name)
  end
end
