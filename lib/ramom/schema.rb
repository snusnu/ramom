# encoding: utf-8

module Ramom
  class Schema < BasicObject

    def self.define(options, &block)
      Definition.build(options, &block)
    end

    def self.build(adapter, definition, base = self, *args)
      Builder.call(adapter, definition, base, *args)
    end

    def initialize(definition)
      @base_relations    = definition.base_relations
      @virtual_relations = definition.virtual_relations
      @fk_constraints    = definition.fk_constraints
    end

    module API

      # TODO only allow to call external relations
      def call(name, *args, &block)
        __send__(name, *args, &block).optimize
      end

      # Useful relational operators not present in axiom

      def allbut(relation, attribute_names)
        relation.project(attr_names(relation) - attribute_names)
      end

      def page(relation, order, number, limit)
        frame(relation, order, number * limit - limit, limit)
      end

      def frame(relation, order, offset, limit)
        relation.sort_by(order).drop(offset).take(limit)
      end

      def matching(left, right)
        left.join(right).project(attr_names(left))
      end

      def not_matching(left, right)
        left - matching(left, right)
      end

      def matching_on(left, right, right_names)
        matching(left, right.project(right_names))
      end

      # Make aggregate functions easily available
      #
      def count(relation, attribute_name = nil)
        Aggregate.new(relation).count(attribute_name)
      end

      # Helper for pagination UX

      PAGE_DETAILS_ATTRS = [:number, :limit, :total].freeze

      def with_page_info(relation, page_details)
        page_details.inject(relation) { |rel, (name, details)|
          rel.extend { |r|
            r.add(:number, details.fetch(:number))
            r.add(:limit,  details.fetch(:limit))
            r.add(:total,  count(details.fetch(:rel)))
          }.wrap(name => PAGE_DETAILS_ATTRS)
        }
      end

      private

      def attr_names(relation)
        relation.header.map(&:name)
      end

      alias_method :h, :attr_names

      def puts(*args)
        ::Kernel.puts(*args)
      end

      def pp(*args)
        ::Kernel.pp(*args)
      end
    end # API

    include API

  end # Schema
end # Ramom
