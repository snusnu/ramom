# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      include Concord.new(:context)

      attr_reader :base_relations
      attr_reader :virtual_relations

      def initialize(*)
        super
        @base_relations    = context.base
        @virtual_relations = context.virtual
      end
    end # Definition
  end # Schema
end # Ramom
