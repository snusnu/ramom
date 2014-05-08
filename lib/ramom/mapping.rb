# encoding: utf-8

module Ramom

  class Mapping

    include Concord.new(:mappers, :registry)

    def initialize(mappers, registry = EMPTY_HASH, &block)
      super(mappers, registry.dup)
      instance_eval(&block)
    end

    def [](name)
      registry.fetch(name)
    end

    private

    def map(relation_name, mapper_name)
      registry[relation_name] = mappers.mapper(mapper_name)
    end
  end # Mapping
end # Ramom
