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

            mapper_name = ::Mom.singularize(name)
            attr_names  = base_relation.header.map(&:name)
            attributes  = attributes_hash(mapper_name, attr_names)

            fk_set        = fk_constraints.fetch(name)
            fk_attr_names = Schema::FKConstraint::Set.fk_attributes(fk_set).to_a

            definition_registry.register(mapper_name) do
              fk_set.each do |fk|
                wrap(::Mom.singularize(fk.target)) do
                  fk.source_attributes.each do |attr_name|
                    map(Mom.attribute_name(attr_name, fk.target))
                  end
                end
              end
              (attr_names - fk_attr_names).each do |attr_name|
                map(attributes.fetch(attr_name))
              end
            end
          end
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
      end # Registrar
    end # Definition
  end # Mom
end # Ramom
