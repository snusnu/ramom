# encoding: utf-8

module Ramom
  class Entity
    class Morpher
      class Builder

        class Attribute

          include AbstractType
          include Adamantium::Flat
          include ::Morpher::NodeHelpers

          def self.call(attribute, environment, builder)
            new(attribute, environment, builder).call
          end

          abstract_method :node

          attr_reader :attribute
          private     :attribute

          attr_reader :name
          private     :name

          attr_reader :options
          private     :options

          attr_reader :environment
          private     :environment

          attr_reader :definitions
          private     :definitions

          attr_reader :processors
          private     :processors

          attr_reader :models
          private     :models

          attr_reader :default_options
          private     :default_options

          attr_reader :builder
          private     :builder

          def initialize(attribute, environment, builder)
            @attribute       = attribute
            @name            = attribute.name
            @options         = attribute.options
            @environment     = environment
            @definitions     = environment.definitions
            @processors      = environment.processors
            @models          = environment.models
            @default_options = environment.default_options
            @builder         = builder

            @old_key = attribute.old_key
            @new_key = attribute.new_key
          end

          def call
            s(:key_transform, @old_key, @new_key, node)
          end

        end # Attribute
      end # Builder
    end # Morpher
  end # Entity
end # Ramom
