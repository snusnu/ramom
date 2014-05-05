# encoding: utf-8

module Ramom
  class Entity
    module Model

      class Builder

        include Concord.new(:registry)

        REGISTRY = {}

        def self.call(name, registry)
          Registry.new(name, builder(name, registry).call)
        end

        def self.builder(name, registry)
          REGISTRY.fetch(name).new(registry)
        end

        def self.registered?(name)
          REGISTRY.key?(name)
        end

        def self.register(name)
          REGISTRY[name] = self
        end
        private_class_method :register

      end # Builder
    end # Model
  end # Entity
end # Ramom
