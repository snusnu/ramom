# encoding: utf-8

module Ramom
  module Mom

    def self.definition_options(schema_definition)
      {
        guard:          false,
        name_generator: Naming::NaturalJoin.new(schema_definition.fk_mapping)
      }
    end
  end # Mom
end # Ramom

require 'ramom/mom/entity_builder'
