# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Builder

      DEFAULT_OPTIONS = { base: Schema }.freeze

      def self.call(options, *args)
        new(DEFAULT_OPTIONS.merge(options)).call(*args)
      end

      include Anima.new(
        :adapters,
        :definition,
        :base
      )

      private :adapters, :definition, :base

      def initialize(_)
        super
        @relations = schema_relations
      end

      def call(*args)
        relation_access = compile(Module.new)

        Class.new(base) {
          include relation_access
        }.new(definition, *args)
      end

      private

      def compile(container)
        container.instance_exec(@relations) do |relations|
          relations.each do |(name, relation)|
            define_method(name, &relation.body)
            send(relation.visibility, name)
          end
        end
        container
      end

      def schema_relations
        definition.relations.each_with_object({}) { |(name, relation), h|
          h[name] = schema_relation(relation)
        }
      end

      def schema_relation(relation)
        if relation.respond_to?(:adapter)
          relation.gateway(adapters.fetch(relation.adapter))
        else
          relation
        end
      end
    end # Builder
  end # Schema
end # Ramom
