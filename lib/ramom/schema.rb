# encoding: utf-8

require 'axiom'
require 'axiom-types'
require 'axiom-optimizer'
require 'axiom-do-adapter'

module Ramom
  class Relation

    class Builder

      include AbstractType
      include Procto.call

      abstract_method :name
      abstract_method :header

      private :name
      private :header

      def call
        Axiom::Relation::Base.new(name, header)
      end

      class DM < self

        include Concord.new(:model)

        private

        def name
          model.storage_name(:default).to_sym
        end

        def header
          model.properties.map { |p| [p.field, p.primitive] }
        end
      end # DM
    end # Builder

    class Schema
      class Definition
        class Builder

          class DM < self

            include Concord.new(:models, :relation_builder)
            include Procto.call

            def initialize(models, relation_builder = Relation::Builder::DM)
              super
            end

            def call
              models.each_with_object({}) { |model, hash|
                relation = relation_builder.call(model)
                hash[relation.name] = relation
              }
            end

          end

          class Context

            include Concord::Public.new(:base, :virtual)

            def self.call(base = EMPTY_HASH, virtual = EMPTY_HASH, &block)
              new(base.dup, virtual.dup).call(&block)
            end

            def call(&block)
              instance_eval(&block)
              self
            end

            private

            def base_relation(name, &block)
              raise NotImplementedError
            end

            def relation(name, &block)
              virtual[name] = block
            end
          end # Context

          include Adamantium::Flat
          include Concord.new(:base, :virtual, :block)
          include Procto.call

          def call
            Definition.new(Context.call(base, virtual, &block))
          end

        end # Builder

        class Context < BasicObject

          def self.call(relations, block)
            new(relations, block).call
          end

          def initialize(relations, block)
            @relations, @block = relations, block
          end

          def call
            instance_eval(&@block).optimize
          end

          def inspect
            @relations.inspect
          end

          private

          def method_missing(name, *args, &block)
            super unless @relations.key?(name)
            @relations[name]
          end

          def respond_to_missing?(name, include_private = false)
            @relations.key?(name) or super
          end
        end # Context

        class Resolver

          include Concord.new(:schema_definition)
          include Adamantium::Flat
          include Procto.call

          def initialize(*)
            super
            @base_relations    = schema_definition.base_relations
            @virtual_relations = schema_definition.virtual_relations
          end

          def call
            base_relations.merge(virtual_relations)
          end

          private

          def base_relations
            @base_relations.each_with_object({}) { |(name, relation), registry|
              registry[name] = base_relation(name, relation)
            }
          end
          memoize :base_relations

          def virtual_relations
            relations = base_relations.dup # minimal hash instance creation
            @virtual_relations.each_with_object({}) { |(name, relation), registry|
              registry[name]  = virtual_relation(relations, relation)
              relations[name] = registry[name] # update the lookup cache
            }
          end
          memoize :virtual_relations

          def base_relation(_name, relation)
            relation # By default this is a noop
          end

          def virtual_relation(registry, block)
            Context.call(registry, block)
          end

        end # Resolver

        include Concord.new(:context)

        attr_reader :base_relations
        attr_reader :virtual_relations

        def initialize(*)
          super
          @base_relations    = context.base
          @virtual_relations = context.virtual
        end

      end # Definition

      include Lupo.collection(:relations)

      def self.define(base_relations, virtual_relations = EMPTY_HASH, &block)
        Definition::Builder.call(base_relations, virtual_relations, block)
      end

      def self.build(base_relations, virtual_relations = EMPTY_HASH, &block)
        definition = define(base_relations, virtual_relations, &block)
        new(definition)
      end

      def [](name)
        @relations.fetch(name)
      end
    end # Schema

    include Concord.new(:relation, :mapper)
    include Enumerable

    def each(&block)
      return to_enum unless block
      relation.each { |tuple| yield(mapper.load(tuple)) }
      self
    end

    def sort
      new(relation.sort)
    end

    def sort_by(*args, &block)
      new(relation.sort_by(*args, &block))
    end

    def one(&block)
      mapper.load(relation.one(&block))
    end

    def restrict(*args, &block)
      new(relation.restrict(*args, &block))
    end

    def wrap(*args)
      new(relation.wrap(*args))
    end

    def group(*args)
      new(relation.group(*args))
    end

    private

    def new(new_relation)
      self.class.new(new_relation, mapper)
    end
  end # Relation

  class Database

    class Builder < Relation::Schema::Definition::Resolver

      def initialize(name, adapter, schema_definition)
        super(schema_definition)
        @name, @adapter = name, adapter
      end

      def call
        Database.new(name, adapter, super)
      end

      private

      attr_reader :name
      attr_reader :adapter

      def base_relation(_, relation)
        Axiom::Relation::Gateway.new(adapter, relation)
      end

    end # Builder

    include Concord.new(:name, :adapter, :relations)

    def self.build(name, adapter, schema_definition)
      Builder.call(name, adapter, schema_definition)
    end

    def [](name)
      relations.fetch(name)
    end

    def query(&block)
      Relation::Schema::Definition::Context.call(relations, block)
    end

  end # Database

  class Schema

    class Builder

      include Concord.new(:relations, :mappers, :entries)

      def self.call(relations, mappers, entries, &block)
        new(relations, mappers, entries, &block).call
      end

      private_class_method :new

      def initialize(*args, &block)
        super(*args); instance_eval(&block)
      end

      def call
        Schema.new(entries)
      end

      private

      def map(relation_name, mapper_name)
        entries[relation_name] = relation(relation_name, mapper_name)
      end

      def relation(relation_name, mapper_name)
        Relation.new(relations[relation_name], mappers.mapper(mapper_name))
      end

    end # Builder

    include Concord.new(:relations)

    def self.build(database, mappers, entries = EMPTY_HASH, &block)
      Builder.call(database, mappers, entries.dup, &block)
    end

    def [](relation_name)
      relations[relation_name]
    end
  end # Schema
end # Ramom
