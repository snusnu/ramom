# encoding: utf-8

module Ramom
  class Entity
    class Definition

      class Registry

        class AlreadyRegistered < StandardError
          def initialize(name)
            super("#{name.inspect} is already registered")
          end
        end # AlreadyRegistered

        DEFAULT_OPTIONS = { key: :neutral, guard: Hash }.freeze

        include Lupo.enumerable(:entries)

        attr_reader :default_options

        attr_reader :entries
        private     :entries

        def self.build(default_options = DEFAULT_OPTIONS, entries = EMPTY_HASH, &block)
          instance = new(default_options, entries)
          instance.instance_eval(&block) if block
          instance
        end

        def initialize(default_options = DEFAULT_OPTIONS, entries = EMPTY_HASH)
          @default_options, @entries = default_options.dup, entries.dup
        end

        def register(name, options = EMPTY_HASH, &block)
          if entries.key?(name)
            fail(AlreadyRegistered.new(name))
          else
            definition_options = @default_options.merge(options)
            entries[name] = Definition.build(name, definition_options, &block)
          end
        end

        def [](name)
          entries.fetch(name)
        end

        def models(builder_name)
          Model::Builder.call(builder_name, self)
        end

        def environment(models, processors = PROCESSORS)
          Environment.new(
            definitions: self,
            models: models,
            processors: processors
          )
        end

      end # Registry
    end # Definition
  end # Entity
end # Ramom
