# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      include Concord.new(:context)

      def self.context(base_relations, fk_constraints, virtual = EMPTY_HASH)
        Builder::Context.new(base_relations, fk_constraints, virtual.dup)
      end

      attr_reader :base_relations
      attr_reader :virtual_relations
      attr_reader :fk_constraints
      attr_reader :fk_attributes

      def initialize(context)
        super
        @base_relations    = context.base
        @virtual_relations = context.virtual
        @fk_constraints    = context.fk_constraints
        @fk_attributes     = fk_constraints.source_attributes
      end

      # TODO think about a better name (for the natural join strategy)
      def fk_mapping
        fk_attributes.each_with_object({}) { |(source_name, attrs), h|
          h[Inflecto.singularize(source_name.to_s).to_sym] = attrs
        }
      end
    end # Definition
  end # Schema
end # Ramom
