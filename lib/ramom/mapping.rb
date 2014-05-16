# encoding: utf-8

module Ramom

  class Mapping

    include Concord.new(:entity_registry, :entries)

    def initialize(entity_registry, entries = EMPTY_HASH, &block)
      super(entity_registry, entries.dup)
      infer_from_definitions
      instance_eval(&block) if block
    end

    def [](name)
      entries.fetch(name)
    end

    private

    def map(relation_name, mapper_name)
      entries[relation_name] = entity_registry.mapper(mapper_name)
    end

    def infer_from_definitions
      entity_registry.definitions.each do |name, definition|
        map(definition.default_options.fetch(:relation, pluralize(name)), name)
      end
    end

    def pluralize(name)
      Inflecto.pluralize(name.to_s).to_sym
    end
  end # Mapping
end # Ramom
