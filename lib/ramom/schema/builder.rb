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
        definition.base_relations.each_with_object({}) { |(name, relation), h|
          h[name] = relation.gateway(adapter(relation))
        }.merge(definition.virtual_relations)
      end

      def adapter(relation)
        adapters.fetch(relation.adapter)
      end
    end # Builder
  end # Schema
end # Ramom
