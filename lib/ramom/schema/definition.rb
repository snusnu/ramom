# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      include Concord.new(:context)

      attr_reader :base_relations
      attr_reader :virtual_relations
      attr_reader :fk_constraints

      def initialize(*)
        super
        @base_relations    = context.base
        @virtual_relations = context.virtual
        @fk_constraints    = context.fk_constraints
      end

      def foreign_keys
        fk_constraints.each_with_object({}) { |(rel_name, fk_c), keys|
          tuple_name = Inflecto.singularize(rel_name.to_s).to_sym
          keys[tuple_name] = fk_c.source_attributes
        }
      end
    end # Definition
  end # Schema
end # Ramom
