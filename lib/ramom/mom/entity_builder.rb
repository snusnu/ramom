# encoding: utf-8

module Ramom
  module Mom

    class EntityBuilder
      include Concord.new(:schema_definition, :definition_registry, :relation_names)
      include Procto.call

      def initialize(schema_definition, definition_registry, relation_names = EMPTY_ARRAY)
        super
      end

      def call
        schema_definition.base_relations.each do |name, base_relation|
          next unless build?(name)

          mapper_name = ::Mom.singularize(name)
          attr_names  = base_relation.header.map(&:name)
          attributes  = attributes_hash(mapper_name, attr_names)

          definition_registry.register(mapper_name) do
            attr_names.each { |attr_name| map(attributes.fetch(attr_name)) }
          end
        end
      end

      private

      def build?(relation_name)
        relation_names.empty? || relation_names.include?(relation_name)
      end

      def attributes_hash(mapper_name, attr_names)
        attr_names.each_with_object({}) { |name, hash|
          hash[name] = mapped_name(name, mapper_name)
        }
      end

      def mapped_name(attr_name, mapper_name)
        attr_name.to_s.sub("#{::Mom.singularize(mapper_name)}_", EMPTY_STRING).to_sym
      end
    end # EntityBuilder
  end # Mom
end # Ramom
