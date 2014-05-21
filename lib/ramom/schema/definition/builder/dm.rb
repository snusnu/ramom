# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      class Builder

        class DM < self

          include Concord.new(:models)
          include Procto.call

          def initialize(models)
            super
          end

          def call
            {
              base_relations: base_relations,
              fk_constraints: fk_constraints
            }
          end

          private

          def base_relations
            models.each_with_object({}) { |model, hash|
              relation = relation_builder.call(model)
              hash[relation.name] = relation
            }
          end

          def fk_constraints
            models.each_with_object(FK_C_HASH.dup) { |model, hash|
              add_fk_constraints(model, hash)
            }
          end

          def add_fk_constraints(model, hash)
            model.relationships.each do |relationship|
              if relationship.respond_to?(:required?) # M:1
                fk = fk_constraint(relationship)
                hash[fk.source] << fk
              end
            end
          end

          def fk_constraint(relationship)
            source_name = relation_name(relationship.source_model)
            target_name = relation_name(relationship.target_model)
            source_key  = key_attributes(relationship.source_key)
            target_key  = key_attributes(relationship.target_key)
            mapping     = Hash[source_key.zip(target_key)]

            FKConstraint.new(source_name, target_name, mapping)
          end

          def relation_name(model)
            model.storage_name(:default).to_sym
          end

          def key_attributes(key)
            key.map { |property| property.field.to_sym }
          end

          def relation_builder
            Relation::Builder::DM
          end
        end # DM
      end # Builder
    end # Definition
  end # Schema
end # Ramom
