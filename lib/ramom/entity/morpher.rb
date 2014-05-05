# encoding: utf-8

module Ramom
  class Entity
    class Morpher

      class TransformError < StandardError
        include Concord::Public.new(:evaluation)

        def message
          evaluation.description
        end
      end

      include Concord.new(:evaluator)

      def self.hash_transformer(definition, environment)
        transformer(:hash, definition, environment)
      end

      def self.object_mapper(definition, environment)
        transformer(:object, definition, environment)
      end

      def self.transformer(name, definition, environment)
        compile(Builder::Entity.call(name, definition, environment))
      end

      def self.compile(node)
        new(::Morpher.compile(node))
      end

      def call(input)
        evaluator.call(input)
      rescue ::Morpher::Evaluator::Transformer::TransformError
        raise(TransformError.new(evaluation(input)))
      end

      def evaluation(input)
        evaluator.evaluation(input)
      end

      def inverse
        self.class.new(evaluator.inverse)
      end

      def node
        evaluator.node
      end

    end # Morpher
  end # Entity
end # Ramom
