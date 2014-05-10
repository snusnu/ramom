# encoding: utf-8

module Ramom
  class Entity
    class Morpher
      class Builder

        class Attribute

          include AbstractType
          include Concord.new(:attribute, :environment, :builder)
          include Procto.call

          include ::Morpher::NodeHelpers

          abstract_method :node

          def initialize(*)
            super
            @processor   = attribute.processor
            @options     = attribute.options
            @definitions = environment.definitions
          end

          def call
            s(:key_transform, attribute.old_key, attribute.new_key, node)
          end

          private

          attr_reader :processor
          attr_reader :options
          attr_reader :definitions

        end # Attribute
      end # Builder
    end # Morpher
  end # Entity
end # Ramom
