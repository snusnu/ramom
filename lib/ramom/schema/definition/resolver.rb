# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
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
          relations = Module.new
          relations = Compiler::Base.call(base_relations, relations)
          relations = Compiler::Virtual.call(@virtual_relations, relations)

          Class.new(Schema) { include(relations) }
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
    end # Definition
  end # Schema
end # Ramom
