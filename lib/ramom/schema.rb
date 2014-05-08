# encoding: utf-8

module Ramom
  class Schema < BasicObject

    class Builder < Definition::Resolver

      def initialize(adapter, schema_definition)
        super(schema_definition)
        @adapter = adapter
      end

      private

      def base_relation(_, relation)
        Axiom::Relation::Gateway.new(@adapter, relation)
      end
    end # Builder

    def self.define(base_relations, virtual_relations = EMPTY_HASH, &block)
      Definition::Builder.call(base_relations, virtual_relations, block)
    end

    def self.build(*args)
      coerce(*args).new
    end

    def self.coerce(adapter, schema_definition)
      Builder.call(adapter, schema_definition)
    end
  end # Schema
end # Ramom
