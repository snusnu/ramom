# encoding: utf-8

require 'concord'
require 'anima'
require 'morpher'
require 'adamantium'
require 'abstract_type'
require 'lupo'

module Ramom
  class Entity

    # An undefined value useful for default params
    Undefined = Class.new.freeze

    # An empty frozen array
    EMPTY_ARRAY = [].freeze

    # An empty frozen array
    EMPTY_HASH = {}.freeze

    def self.registry(environment)
      Registry.new(environment.definitions.each_with_object({}) {
        |(name, definition), hash|
        hash[name] = build(definition, environment)
      })
    end

    def self.definition_registry(options = EMPTY_HASH)
      Definition::Registry.new(options)
    end

    def self.build(definition, environment)
      name   = definition.entity_name
      model  = environment.model(name)
      mapper = Mapper.build(definition, environment)

      new(name, model, mapper)
    end
    private_class_method :build

    include Concord::Public.new(:name, :model, :mapper)

    def new(attributes)
      model.new(attributes)
    end

    def load(tuple)
      mapper.load(tuple)
    end

    def dump(object)
      mapper.dump(object)
    end
  end # Entity
end # Ramom

