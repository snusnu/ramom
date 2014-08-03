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

      def initialize(_)
        super
        base_relations    = base_relations(definition.base_relations)
        virtual_relations = definition.virtual_relations

        @relations = base_relations.merge(virtual_relations)
      end

      def call(*args)
        relations = compile(Module.new)
        Class.new(base) { include(relations) }.new(definition, *args)
      end

      private

      attr_reader :relations

      def compile(container)
        container.instance_exec(relations) do |relations|
          relations.each do |(name, relation)|
            define_method(name, &relation.body)
            send(relation.visibility, name)
          end
        end
        container
      end

      def base_relations(relations)
        relations.each_with_object({}) { |(name, relation), h|
          h[name] = relation.gateway(adapter(relation))
        }
      end

      def adapter(relation)
        adapters.fetch(relation.adapter)
      end
    end # Builder
  end # Schema
end # Ramom
