# encoding: utf-8

module Ramom
  class Entity
    module Model
      class Builder

        class Anima < self

          include ::Morpher::NodeHelpers

          register :anima

          def call
            registry.each_with_object({}) { |(name, definition), hash|
              hash[name] = model(definition)
            }
          end

          def model(definition)
            Class.new do
              include ::Anima.new(*definition.attribute_names)

              define_singleton_method :name do
                "Entity(#{definition.entity_name})"
              end
            end
          end

          def processor(definition)
            s(:load_attribute_hash, s(:param, registry.fetch(definition.entity_name) {
              model(definition)
            }))
          end

        end # Anima
      end # Builder
    end # Model
  end # Entity
end # Ramom
