# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      class Builder

        class DM < self

          include Concord.new(:models, :relation_builder)
          include Procto.call

          def initialize(models, relation_builder = Relation::Builder::DM)
            super
          end

          def call
            models.each_with_object({}) { |model, hash|
              relation = relation_builder.call(model)
              hash[relation.name] = relation
            }
          end
        end # DM
      end # Builder
    end # Definition
  end # Schema
end # Ramom
