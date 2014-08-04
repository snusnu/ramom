# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition

      DEFAULT_OPTIONS = {
        base:           {},
        virtual:        {},
        fk_constraints: FKConstraint::Set.new
      }.freeze

      def self.build(options, &block)
        new(Context.new(DEFAULT_OPTIONS.dup.merge(options), &block))
      end

      include Concord.new(:context)

      attr_reader :base_relations
      attr_reader :virtual_relations
      attr_reader :relations

      attr_reader :fk_constraints
      attr_reader :fk_attributes
      attr_reader :fk_mapping # TODO think about a better name

      def initialize(context)
        super
        @base_relations    = context.base
        @virtual_relations = context.virtual
        @relations         = @base_relations.merge(@virtual_relations)
        @fk_constraints    = context.fk_constraints
        @fk_attributes     = fk_constraints.source_attributes
        @fk_mapping        = initialize_fk_mapping

        # Cache these because Schema#call relies on #relation?
        @public_relations  = initialize_public_relation_cache
      end

      def relation?(name, include_private = false)
        (include_private ? relations : @public_relations).key?(name)
      end

      private

      def initialize_fk_mapping
        fk_attributes.each_with_object({}) { |(source_name, attrs), h|
          h[Inflecto.singularize(source_name.to_s).to_sym] = attrs
        }
      end

      def initialize_public_relation_cache
        @relations.each_with_object({}) { |(name, relation), h|
          h[name] = relation if relation.external?
        }
      end
    end # Definition
  end # Schema
end # Ramom
