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

    DEFAULT_OPTIONS = {
      base:           EMPTY_HASH,
      virtual:        EMPTY_HASH,
      fk_constraints: Definition::FKConstraint::Set.new
    }.freeze

    def self.define(options, &block)
      Definition::Builder.call(DEFAULT_OPTIONS.merge(options).merge!(block: block))
    end

    def self.build(*args)
      coerce(*args).new
    end

    def self.coerce(adapter, schema_definition)
      Builder.call(adapter, schema_definition)
    end
  end # Schema
end # Ramom
