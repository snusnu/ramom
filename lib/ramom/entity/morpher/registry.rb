# encoding: utf-8

module Ramom
  class Entity
    class Morpher

      class Registry

        class Builder
          include Concord.new(:definitions, :models)

          def call
            Registry.new(entries)
          end

          private

          def entries
            definitions.each_with_object({}) { |(name, definition), hash|
              hash[name] = Morpher::Builder.call(definition, definitions, models)
            }
          end
        end # Builder

        include Lupo.collection(:entries)

        def self.build(definitions)
          new(Builder.call(definitions))
        end

        def [](name)
          entries.fetch(name)
        end
      end # Registry
    end # Morpher
  end # Entity
end # Ramom
