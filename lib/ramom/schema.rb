# encoding: utf-8

module Ramom
  class Schema < BasicObject

    def self.define(options, &block)
      Definition.build(options, &block)
    end

    def self.build(options, *args)
      Builder.call(options, *args)
    end

    def initialize(definition)
      @definition        = definition
      @base_relations    = @definition.base_relations
      @virtual_relations = @definition.virtual_relations
      @fk_constraints    = @definition.fk_constraints
    end

    module API

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

      def fk_wrapped_rel(name)
        FKWrapper.call(name, call(name), @fk_constraints)
      end

      private

      def attr_names(relation)
        relation.header.map(&:name)
      end

      alias_method :h, :attr_names

    end # API

    include API

    def public_send(name, *args, &block)
      if @definition.relation?(name)
        __send__(name, *args, &block).optimize
      else
        fail ::NoMethodError, "private method `#{name}' called for #{self}"
      end
    end

    alias_method :call, :public_send

    def respond_to?(name, include_private = false)
      @definition.relation?(name, include_private)
    end

    def to_s
      "#<Ramom::Schema(BasicObject):#{__id__}>"
    end

    def puts(*args)
      ::Kernel.puts(*args)
    end

    def pp(*args)
      ::Kernel.pp(*args)
    end

    def fail(*args)
      ::Kernel.fail(*args)
    end

    def raise(*args)
      ::Kernel.raise(*args)
    end
  end # Schema
end # Ramom
