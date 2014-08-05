# encoding: utf-8

module Ramom
  module DM
    module Relation

      class Registry

        class Mapping
          include Concord.new(:mapping)

          def initialize(mapping = EMPTY_HASH, &block)
            super(mapping.dup)
            instance_eval(&block) if block
          end

          def call(model)
            [relation_name(model), model]
          end

          private

          def map(relation_name, model)
            mapping[model.name] = relation_name
          end

          def relation_name(model)
            mapping.fetch(model.name, model.storage_name.to_sym)
          end
        end # Mapping

        include Concord.new(:relations)

        def self.build(models, &block)
          mapping = Mapping.new(&block)
          new(models.each_with_object({}) { |model, h|
            relation_name, mapped_model = mapping.call(model)
            h[relation_name] = mapped_model
          })
        end

        def [](name)
          relations.fetch(name)
        end
      end # Registry
    end # Relation
  end # DM
end # Ramom
