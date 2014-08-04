# encoding: utf-8

module Ramom
  module Mom

    def self.definition_registry(schema_definition, names = EMPTY_ARRAY, &block)
      options  = definition_options(schema_definition)
      registry = ::Mom.definition_registry(options, &block)
      Definition::Registrar.call(schema_definition, registry, names)
    end

    def self.definition_options(schema_definition)
      {
        guard:          false,
        name_generator: Naming::NaturalJoin.new(schema_definition.fk_mapping)
      }
    end
    private_class_method :definition_options

    def self.attribute_name(prefixed_name, relation_name)
      prefix = "#{::Mom.singularize(relation_name)}_"
      prefixed_name.to_s.sub(prefix, EMPTY_STRING).to_sym
    end
  end # Mom
end # Ramom

require 'ramom/mom/definition/registrar'
