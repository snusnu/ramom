# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Builder

      def self.call(adapter, definition, base = self, *args)
        new(adapter, definition, base).call(*args)
      end

      include Concord.new(:adapter, :definition, :base)

      def initialize(*)
        super
        @base_relations    = base_relations(definition.base_relations)
        @virtual_relations = definition.virtual_relations
      end

      def call(*args)
        relations = Module.new

        # Compile relation access methods onto +relations+ lvar
        Definition::Compiler::Base.call(@base_relations, relations)
        Definition::Compiler::Virtual.call(@virtual_relations, relations)

        Class.new(base) { include(relations) }.new(definition, *args)
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
