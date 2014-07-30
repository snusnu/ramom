# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Builder

      include Concord.new(:adapter, :schema_definition)
      include Adamantium::Flat
      include Procto.call

      def initialize(*)
        super
        @base_relations    = base_relations(schema_definition.base_relations)
        @virtual_relations = schema_definition.virtual_relations
      end

      def call
        relations = Module.new

        # Compile relation access methods onto +relations+ lvar
        Definition::Compiler::Base.call(@base_relations, relations)
        Definition::Compiler::Virtual.call(@virtual_relations, relations)

        Class.new(Schema) { include(relations) }
      end

      private

      def base_relations(relations)
        relations.each_with_object({}) { |(name, relation), h|
          h[name] = Axiom::Relation::Gateway.new(adapter, relation)
        }
      end
    end # Builder
  end # Schema
end # Ramom
