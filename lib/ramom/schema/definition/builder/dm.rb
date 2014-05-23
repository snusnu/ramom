# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      class Builder

        class DM < self

          include Concord.new(:models, :fk_constraints)
          include Procto.call

          # This object mutates the injected +fk_constraints+
          def initialize(models, fk_constraints = FKConstraint::Set.new)
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
              add_fk_constraints(model)

              fk_attributes  = fk_constraints.source_attributes
              name_generator = Mapping::NaturalJoin.new(fk_attributes)

              source_name = relation_name(model)
              relation    = relation_builder.call(model, name_generator)
              hash[source_name] = relation
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

            fk_constraints.add(source_name, target_name, mapping)
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
