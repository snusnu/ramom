# encoding: utf-8

module Ramom
  class Schema
    class Mapping

      def self.default_options(schema_definition)
        {
          guard:          false,
          name_generator: NaturalJoin.new(schema_definition.fk_mapping)
        }
      end
    end # Mapping
  end # Schema
end # Ramom
