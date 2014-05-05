# encoding: utf-8

module Ramom
  class Entity

    extend ::Morpher::NodeHelpers

    PROCESSORS = {

      Noop:             ->(_) { s(:input) },

      ParsedInt10:      ->(_) { s(:parse_int, 10) },
      ParsedInt10Array: ->(_) { s(:map, s(:parse_int, 10)) },

      String:           ->(_) { s(:guard, s(:primitive, String)) },
      Integer:          ->(_) { s(:guard, s(:is_a,      Integer)) },
      Date:             ->(_) { s(:guard, s(:primitive, Date)) },
      DateTime:         ->(_) { s(:guard, s(:primitive, DateTime)) },
      Boolean:          ->(_) { s(:guard, s(:or, s(:primitive, TrueClass), s(:primitive, FalseClass))) },

      OString:          ->(_) { s(:guard, s(:or, s(:primitive, String),   s(:primitive, NilClass))) },
      OInteger:         ->(_) { s(:guard, s(:or, s(:is_a,      Integer),  s(:primitive, NilClass))) },
      ODate:            ->(_) { s(:guard, s(:or, s(:primitive, Date),     s(:primitive, NilClass))) },
      ODateTime:        ->(_) { s(:guard, s(:or, s(:primitive, DateTime), s(:primitive, NilClass))) },

      IntArray:         ->(_) { s(:map, s(:guard, s(:is_a,      Integer))) },
      StringArray:      ->(_) { s(:map, s(:guard, s(:primitive, String))) },

      OIntArray:        ->(_) {
        s(:block,
          s(:guard,
            s(:or,
              s(:primitive, NilClass),
              s(:primitive, Array))),
          s(:map, s(:guard, s(:is_a, Integer))))
      }

    }.freeze

    class Environment

      include Enumerable

      include Anima.new(
        :definitions,
        :processors,
        :models
      )

      DEFAULTS = {
        processors: PROCESSORS
      }.freeze

      def self.new(attributes)
        super(DEFAULTS.merge(attributes))
      end

      def each(&block)
        return to_enum(__method__) unless block
        definitions.each(&block)
        self
      end

      def hash_transformer(entity_name = :anonymous, &block)
        Morpher.hash_transformer(definition(entity_name, &block), self)
      end

      def object_mapper(entity_name = :anonymous, &block)
        Morpher.object_mapper(definition(entity_name, &block), self)
      end

      def mapper(entity_name)
        Mapper.build(definitions[entity_name], self)
      end

      def processor(name, options)
        processors.fetch(name).call(options)
      end

      def model(name)
        models[name]
      end

      def model_processor(definition)
        models.processor(definition)
      end

      def default_options
        definitions.default_options
      end

      private

      def definition(entity_name, &block)
        Definition.build(entity_name, &block)
      end

    end # Environment
  end # Entity
end # Ramom
