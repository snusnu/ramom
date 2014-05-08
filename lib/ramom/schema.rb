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
  end # Relation

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

          class Future
            include Concord::Public.new(:name, :body)
          end

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
            virtual[name] = Future.new(name, block)
          end
        end # Context

        include Adamantium::Flat
        include Concord.new(:base, :virtual, :block)
        include Procto.call

        def call
          Definition.new(Context.call(base, virtual, &block))
        end

      end # Builder

      class Resolver

        class Compiler
          include AbstractType
          include Concord.new(:relations, :container)
          include Procto.call

          abstract_method :call

          class Base < self
            def call
              relations = self.relations
              container.module_eval do
                relations.each do |(name, relation)|
                  define_method(name) { relation }
                end
              end
              container
            end
          end # Base

          class Virtual < self
            def call
              relations = self.relations
              container.module_eval do
                relations.each do |(name, relation)|
                  define_method(name, &relation.body)
                end
              end
              container
            end
          end # Virtual
        end # Compiler

        include Concord.new(:schema_definition)
        include Adamantium::Flat
        include Procto.call

        def initialize(*)
          super
          @base_relations    = schema_definition.base_relations
          @virtual_relations = schema_definition.virtual_relations
        end

        def call
          relations = Module.new
          relations = Compiler::Base.call(base_relations, relations)
          relations = Compiler::Virtual.call(@virtual_relations, relations)

          Class.new(Database) { include(relations) }
        end

        private

        def base_relations
          @base_relations.each_with_object({}) { |(name, relation), relations|
            relations[name] = base_relation(name, relation)
          }
        end

        def base_relation(_name, relation)
          relation # This is a NOOP because I use DM1 base relations
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

    def [](name)
      @relations.fetch(name)
    end
  end # Schema

  class Database #< BasicObject

    class Builder < Schema::Definition::Resolver

      def initialize(adapter, schema_definition)
        super(schema_definition)
        @adapter = adapter
      end

      private

      def base_relation(_, relation)
        Axiom::Relation::Gateway.new(@adapter, relation)
      end

    end # Builder

    def self.build(*args)
      coerce(*args).new
    end

    def self.coerce(adapter, schema_definition)
      Builder.call(adapter, schema_definition)
    end

  end # Database

  class Mapping

    include Concord.new(:mappers, :registry)

    def initialize(mappers, registry = EMPTY_HASH, &block)
      super(mappers, registry.dup)
      instance_eval(&block)
    end

    def [](name)
      registry.fetch(name)
    end

    private

    def map(relation_name, mapper_name)
      registry[relation_name] = mappers.mapper(mapper_name)
    end
  end # Mapping

  class Reader
    include Concord.new(:database, :mapping)

    def self.build(adapter, schema_definition, mapping)
      new(Database.build(adapter, schema_definition), mapping)
    end

    def read(name, *args)
      relation(name, *args).map do |tuple|
        mapping[name].load(tuple)
      end
    end

    def query(&block)
      database.query(&block)
    end

    def one(name, *args, &block)
      mapping[name].load(sort(name, *args).one(&block))
    end

    def sort(name, *args)
      relation(name, *args).sort
    end

    def sort_by(name, *args, &block)
      relation(name, *args).sort_by(&block)
    end

    private

    def relation(name, *args)
      database.public_send(name, *args)
    end
  end
end # Ramom
