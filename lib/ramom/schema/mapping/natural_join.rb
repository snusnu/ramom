# encoding: utf-8

module Ramom
  class Schema
    class Mapping
        class NaturalJoin
          include Concord.new(:fk_attributes)

          def call(base_name, attribute_name)
            return attribute_name if fk_attribute?(base_name, attribute_name)
            :"#{Inflecto.singularize(base_name)}_#{attribute_name}"
          end

          private

          def fk_attribute?(base_name, attribute_name)
            fk_attributes.fetch(base_name, EMPTY_ARRAY).include?(attribute_name)
          end
        end # NaturalJoin
    end # Mapping
  end # Schema
end # Ramom
