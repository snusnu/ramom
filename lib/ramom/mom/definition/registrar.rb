# encoding: utf-8

module Ramom
  module Mom
    module Definition

      class Registrar
        include Concord.new(:schema_definition, :definition_registry, :relation_names)
        include Procto.call

        def initialize(schema_definition, definition_registry, relation_names = EMPTY_ARRAY)
          super
          @fk_constraints = schema_definition.fk_constraints
        end

        def call
          schema_definition.base_relations.each do |name, base_relation|
            next unless build?(name)

            mapper_name    = ::Mom.singularize(name)
            tva_attributes = tva_attributes(name)
            attributes     = attributes(base_relation, mapper_name)

            definition_registry.register(mapper_name) do
              tva_attributes.each do |tva_name, tva_attr_names|
                wrap(tva_name) do
                  tva_attr_names.each { |attr_name| map(attr_name) }
                end
              end
              attributes.each { |attr_name| map(attr_name) }
            end
          end
          definition_registry
        end

        private

        attr_reader :fk_constraints

        def build?(relation_name)
          relation_names.empty? || relation_names.include?(relation_name)
        end

        def attributes_hash(mapper_name, attr_names)
          attr_names.each_with_object({}) { |name, h|
            h[name] = Mom.attribute_name(name, mapper_name)
          }
        end

        def tva_attributes(base_name)
          fk_constraints.fetch(base_name).each_with_object({}) { |fk, h|
            h[::Mom.singularize(fk.target)] = fk.source_attributes.map { |name|
              Mom.attribute_name(name, fk.target)
            }
          }
        end

        def attributes(base_relation, mapper_name)
          attr_names    = base_relation.attr_names
          fk_set        = fk_constraints.fetch(base_relation.name)
          fk_attr_names = Schema::FKConstraint::Set.fk_attributes(fk_set)
          attributes    = attributes_hash(mapper_name, attr_names)

          (attr_names - fk_attr_names).map { |name| attributes.fetch(name) }
        end
      end # Registrar
    end # Definition
  end # Mom
end # Ramom
