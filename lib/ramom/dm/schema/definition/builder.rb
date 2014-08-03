# encoding: utf-8

module Ramom
  module DM
    module Schema
      module Definition

        class Builder

          DM_ADAPTER_KEY = 'adapter'.freeze

          def self.adapter(model)
            model.repository.adapter.options[DM_ADAPTER_KEY].to_sym
          end

          include Concord.new(:models, :context)

          def self.call(models, &block)
            new(models).call(&block)
          end

          # This object mutates the injected +context+
          def initialize(_, context = Ramom::Schema::Definition::Context.new)
            super
            infer_base_relations
          end

          def call(&block)
            Ramom::Schema::Definition.new(context.call(&block))
          end

          private

          def infer_base_relations
            models.each_with_object({}) { |model, h|
              add_fk_constraints(model)

              fk_attributes  = context.fk_constraints.source_attributes
              name_generator = Naming::NaturalJoin.new(fk_attributes)

              name     = relation_name(model)
              options  = {adapter: self.class.adapter(model), visibility: :public}
              relation = Relation::Builder.call(model, name_generator)

              context.base_relation(name, options) { relation }
            }
          end

          def add_fk_constraints(model)
            model.relationships.each do |relationship|
              if relationship.respond_to?(:required?) # M:1
                add_fk_constraint(relationship)
              end
            end
          end

          def add_fk_constraint(relationship)
            source_name = relation_name(relationship.source_model)
            target_name = relation_name(relationship.target_model)
            source_key  = key_attributes(relationship.source_key)
            target_key  = key_attributes(relationship.target_key)
            mapping     = Hash[source_key.zip(target_key)]

            context.fk_constraint(source_name, target_name, mapping)
          end

          def relation_name(model)
            model.storage_name(:default).to_sym
          end

          def key_attributes(key)
            key.map { |property| property.field.to_sym }
          end
        end # Builder
      end # Definition
    end # Schema
  end # DM
end # Ramom
