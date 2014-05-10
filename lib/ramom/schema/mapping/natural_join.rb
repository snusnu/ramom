# encoding: utf-8

module Ramom
  class Schema
    class Mapping
        class NaturalJoin
          include Concord.new(:exclusions)

          def call(base_name, attribute_name)
            if exclude?(base_name, attribute_name)
              attribute_name
            else
              :"#{Inflecto.singularize(base_name)}_#{attribute_name}"
            end
          end

          private

          def exclude?(base_name, attribute_name)
            if prefix = exclusions.fetch(base_name, false)
              prefix.include?(attribute_name)
            else
              false
            end
          end
        end # NaturalJoin
    end # Mapping
  end # Schema
end # Ramom
