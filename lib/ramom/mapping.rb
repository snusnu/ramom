# encoding: utf-8

module Ramom

  class Mapping

    include Concord.new(:entity_registry, :entries)

    def initialize(entity_registry, entries = EMPTY_HASH, &block)
      super(entity_registry, entries.dup)
      instance_eval(&block)
    end

    def [](name)
      entries.fetch(name)
    end

    private

    def map(relation_name, mapper_name)
      entries[relation_name] = entity_registry.mapper(mapper_name)
    end
  end # Mapping
end # Ramom
