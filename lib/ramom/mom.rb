# encoding: utf-8

module Ramom
  module Mom

    def self.definition_options(schema_definition)
      {
        guard:          false,
        name_generator: Naming::NaturalJoin.new(schema_definition.fk_mapping)
      }
    end

    def self.register_base_relation_definitions(schema_definition, definition_registry, names = EMPTY_ARRAY)
      Definition::Registrar.call(schema_definition, definition_registry, names)
    end

    def self.attribute_name(prefixed_name, relation_name)
      prefix = "#{::Mom.singularize(relation_name)}_"
      prefixed_name.to_s.sub(prefix, EMPTY_STRING).to_sym
    end
  end # Mom
end # Ramom

require 'ramom/mom/definition/registrar'
