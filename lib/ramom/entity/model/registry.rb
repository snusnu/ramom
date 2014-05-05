# encoding: utf-8

module Ramom
  class Entity
    module Model

      class Registry
        include Concord.new(:name, :entries)

        def [](model_name)
          fetch(model_name)
        end

        def fetch(model_name, &block)
          entries.fetch(model_name, &block)
        end

        def processor(definition)
          Builder.builder(name, self).processor(definition)
        end

      end # Registry
    end # Model
  end # Entity
end # Ramom
