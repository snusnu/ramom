# encoding: utf-8

module Ramom
  class Entity
    class Definition

      class Attribute

        include AbstractType
        include Concord::Public.new(:name, :options)
        include Adamantium::Flat

        abstract_method :builder

        def initialize(name, options)
          super(name.to_sym, options)
        end

        def node(environment, entity_builder_name)
          builder.call(self, environment, entity_builder_name)
        end

        def processor
          options.fetch(:processor, :Noop)
        end
        memoize :processor

        def default_value
          options.fetch(:default, Undefined)
        end
        memoize :default_value

        def default_value?
          !default_value.equal?(Undefined)
        end

        def old_key
          case options[:key]
          when :neutral
            fetch_old_key(name)
          when :symbolize
            fetch_old_key(name).to_s
          else
            fetch_old_key(name)
          end
        end

        def new_key
          case options[:key]
          when :neutral
            name
          when :symbolize
            name.to_sym
          else
            name
          end
        end

        def primitive?
          false
        end

        private

        def fetch_old_key(name)
          options.fetch(:from, name)
        end

      end # Attribute
    end # Definition
  end # Entity
end # Ramom
