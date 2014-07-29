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
      fk_constraints: FKConstraint::Set.new
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

    # TODO only allow to call external relations
    def call(name, *args, &block)
      __send__(name, *args, &block).optimize
    end

    # Useful relational operators not present in axiom

    def page(relation, order, number, limit)
      frame(relation, order, number * limit - limit, limit)
    end

    def frame(relation, order, offset, limit)
      relation.sort_by(order).drop(offset).take(limit)
    end

    # Make aggregate functions easily available
    #
    def count(relation, attribute_name = nil)
      Aggregate.new(relation).count(attribute_name)
    end

    # Helper for pagination UX

    PAGE_DETAILS_ATTRS = [:number, :limit, :total].freeze

    def add_page_info(relation, page_details)
      page_details.inject(relation) { |rel, (name, details)|
        rel.extend { |r|
          r.add(:number, details.fetch(:number))
          r.add(:limit,  details.fetch(:limit))
          r.add(:total,  count(details.fetch(:rel)))
        }.wrap(name => PAGE_DETAILS_ATTRS)
      }
    end

    private

    def puts(*args)
      ::Kernel.puts(*args)
    end

    def pp(*args)
      ::Kernel.pp(*args)
    end
  end # Schema
end # Ramom
