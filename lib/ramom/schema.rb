# encoding: utf-8

module Ramom
  class Schema < BasicObject

    def self.define(options, &block)
      Definition::Builder.call(options, &block)
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

    def header(relation)
      relation.header.map(&:name)
    end

    alias_method :h, :header

    def puts(*args)
      ::Kernel.puts(*args)
    end

    def pp(*args)
      ::Kernel.pp(*args)
    end
  end # Schema
end # Ramom
