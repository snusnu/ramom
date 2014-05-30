# ramom

[![Gem Version](https://badge.fury.io/rb/ramom.png)][gem]
[![Build Status](https://secure.travis-ci.org/snusnu/ramom.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/snusnu/ramom.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/snusnu/ramom.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/snusnu/ramom/badge.png?branch=master)][coveralls]

[gem]: https://rubygems.org/gems/ramom
[travis]: https://travis-ci.org/snusnu/ramom
[gemnasium]: https://gemnasium.com/snusnu/ramom
[codeclimate]: https://codeclimate.com/github/snusnu/ramom
[coveralls]: https://coveralls.io/r/snusnu/ramom

## Usage

Currently, `ramom`'s focus is on reading database content. If you have
defined your database with [datamapper](https://github.com/datamapper),
`ramom` provides all the necessary integrations to get you going in no
time.

Assuming that you have a set of datamapper models and a few records
stored already

```ruby
uri = 'postgres://localhost/test'.freeze

DataMapper.logger = DataMapper::Logger.new($stdout, :debug) if ::ENV['LOG']
DataMapper.setup(:default, uri)

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

  belongs_to :account
  has n, :tasks
end

class Task
  include DataMapper::Resource

  property :id,        Serial
  property :name,      String

  belongs_to :person
end

DataMapper.finalize.auto_migrate!

Person.create(
  name:     'snusnu',
  nickname: 'gams',
  account:  { email: 'test@test.com' },
  tasks:    [{name: 'test'}]
)
```

You can then initialize a new `Ramom::Schema` ready to be queried by first
inferring the information needed from `DataMapper::Model.descendants` and
passing that as options to `Ramom::Schema.define`.

```ruby
models        = DataMapper::Model.descendants
dm_definition = Ramom::Schema::Definition::Builder::DM.call(models)

options = {
  base:           dm_definition[:base_relations],
  fk_constraints: dm_definition[:fk_constraints]
}
```

`ramom` will automatically generate all base relations based on the information
found in `DataMapper::Model.descendants`. Base relations correspond with tables
in an SQL database, their equivalents in `DataMapper` code are therefore all
descendants of `DataMapper::Model`. `ramom` infers all column names, their types
and all the *keys* for every base relation. It also infers all *foreign key constraints*
based on the `belongs_to` definitions in the DataMapper models.

Only querying raw tables doesn't help much tho, you need a way to write arbitrary
queries, joining a few tables, restricting on some predicates and so on. `ramom`
is based on *relational algebra* (by using [axiom](https://github.com/dkubb/axiom))
internally, so from now on, we will use relational algebra terms instead of their
SQL counterparts. Specifically, we'll say *base relation* instead of *table*, and
*virtual relation* instead of *query*.

In contrast to most `ORM`s, `ramom` (currently) defines no API for *ad-hoc* queries,
instead, you register any number of *virtual relations* with your schema. You can
think of preregistered virtual relations much like methods that encapsulate a query.
You can chain them *arbitrarily*, further composing more complex relations (by reusing
simpler ones). Much like with regular methods, you typically don't want/need to
expose all of them (i.e. make them `public`). `ramom` allows to define "public" relations
using the `external` method inside a schema definition, and supports "private" relations
using the `internal` method. While `external` relations will typically be called from
client code (i.e. your application code), `internal` relations aren't exposed, but simply
help with defining the `external` ones.

Just as regular ruby methods take parameters, virtual relations oftentimes need to
accept parameters too, in order to be *context aware*. By *context aware*, we mean
that oftentimes we need to restrict a relation based on, say, the currently logged
in `account_id`. It's easy to do that with `ramom`, just make the block that defines
a relation accept any parameters you like. You can still compose these relations
arbitrarily, you just need to remember to pass all the relevant parameters to any
relation invocation.

```ruby
schema_definition = Ramom::Schema.define(options) do

  # These have been inferred from DM1 models
  # fk_constraint :people, :accounts, account_id: :account_id
  # fk_constraint :tasks,  :people,   person_id:  :person_id

  # Here we define a context aware relation that needs
  # an account_id in order to perform a restriction
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
```

Once we have our relation schema set up, we can (optionally) define mappers
(by using [mom](https://github.com/snusnu/mom)) in order to be able to access
aptly named *objects* when iterating over the tuples returned from the database.

Mappers mainly act as a way to prettify access to the tuple's attributes, so for
example, in order to be able to call `actor.account.id` instead of `actor[:account_id]`
you tell `ramom` which mappers to use for you virtual relations.

```ruby
definition_options  = Ramom::Schema::Mapping.default_options(schema_definition)
definition_registry = Mom::Definition::Registry.build(definition_options) do

  register :detailed_person, relation: :person_details, prefix: :person do
    map :id
    map :name

    wrap :account do
      map :id
      map :email
    end

    group :tasks do
      map :id
      map :name
    end
  end

  register :detailed_task, relation: :task_details, prefix: :task do
    map :id
    map :name

    wrap :person do
      map :id
      map :name

      wrap :account do
        map :id
        map :email
      end
    end
  end

  register :actor, prefix: :person do
    map :id
    map :name

    wrap :account do
      map :id
      map :email
    end
  end

end
```

Typically, you will need mappers for a few selected base relations too, but
it'd be tedious to manually define them, also, `ramom` already has all the
necessary information to generate them for you (it knows all base relations
and their attributes). The following snippet shows how you can take advantage
of that feature, and have `ramom` generate selected base relation mappers for
you on the fly.

```ruby
# This mutates +definition_registry+ and adds base relation mappers
Ramom::EntityBuilder.call(schema_definition, definition_registry) #, [
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
#  :tasks,
#])
```

Once we have defined all the mappers we're going to use in our app, we can
finally connect all the pieces together. At this point you might have noticed
that we never defined the actual *objects* our mappers are going to use. Until
now, we've simply assumed that there will be, say, an `Actor` class that will
expose all the relevant attributes.

This wasn't by mistake. `ramom` (in fact, `mom`) automatically generates these
classes for you, as it has all the information it needs to do so, available from
the mapper definitions. Since it is the author's belief that this kind of objects
should *never* have any business logic methods attached, it's reasonably to generate
them automatically, only exposing their attributes. Business logic can, and imo always
should, be implemented somewhere else.

In order to tell `mom` exactly "how" to generate these classes, you must tell it
which "model builder" it shall use. The only currently supported model builder is
`:anima`, which builds models using the [anima](https://github.com/mbj/anima) gem.

The first statement in the example code below, shows how to generate model classes
from your mapper definitions.

```ruby
models             = definition_registry.models(:anima)
entity_environment = definition_registry.environment(models)
```

The `entity_environment` created above can then be used to either automatically
generate, or further refine the mapping of relation names to mapper names. By default,
if you don't pass a block to `Ramom::Mapping.new`, it will simply assume that all your
mappers are named in the singular form of your relations names. The block gets evaluated
*after* inferring these mappings, so you can fine tune / overwrite any of the default
mappings.

```ruby
# The commented mappings are inferred automatically
mapping = Ramom::Mapping.new(entity_environment) # do
#  map :accounts,       :account
#  map :people,         :person
#  map :tasks,          :task
#  map :person_details, :detailed_person
#  map :task_details,   :detailed_task
#  map :actors,         :actor
#end
```

Now we're good to go! By passing a database adapter, a schema definition and a mapping
to `Ramom::Reader.build`, we can finally start displaying our database content.

```ruby
describe Ramom do

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
```

## Credits

* [snusnu](https://github.com/snusnu)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Copyright

Copyright &copy; 2014 Martin Gamsjaeger (snusnu). See [LICENSE](LICENSE) for details.
