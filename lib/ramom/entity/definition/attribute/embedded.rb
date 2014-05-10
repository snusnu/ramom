# encoding: utf-8

module Ramom
  class Entity
    class Definition
      class Attribute

        class OptionBuilder
          include Concord.new(:name, :options, :default_options)
          include Procto.call

          def call
            default_options.merge(local_options).merge!(options)
          end

          private

          def local_options
            {entity: name, base: base_name}
          end

          def base_name
            name
          end
        end # OptionBuilder

        class Entity < self

          attr_reader :entity_name
          attr_reader :block

          def self.build(name, options, default_options, block)
            new(name, self::OptionBuilder.call(name, options, default_options), block)
          end

          def initialize(name, options, block)
            super(name, options)
            @entity_name = options.fetch(:entity, name)
            @block       = block
          end

          def embed?
            !!block
          end

          private

          def builder
            Morpher::Builder::Attribute::Entity
          end
        end # Entity

        class Collection < Entity
          class OptionBuilder < Attribute::OptionBuilder
            private

            def base_name
              Inflecto.singularize(super.to_s).to_sym
            end
          end

          private

          def builder
            Morpher::Builder::Attribute::Collection
          end
        end # Collection

      end # Attribute
    end # Definition
  end # Entity
end # Ramom
