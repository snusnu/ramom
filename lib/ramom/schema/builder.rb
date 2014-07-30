# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Builder

      include Concord.new(:adapter, :definition, :base)
      include Procto.call

      def initialize(*)
        super
        @base_relations    = base_relations(definition.base_relations)
        @virtual_relations = definition.virtual_relations
      end

      def call
        relations = Module.new

        # Compile relation access methods onto +relations+ lvar
        Definition::Compiler::Base.call(@base_relations, relations)
        Definition::Compiler::Virtual.call(@virtual_relations, relations)

        Class.new(base) { include(relations) }
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
