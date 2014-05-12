# encoding: utf-8

module Ramom
  class Schema
    class Mapping
        class NaturalJoin
          include Concord.new(:foreign_keys)

          def call(base_name, attribute_name)
            if exclude?(base_name, attribute_name)
              attribute_name
            else
              :"#{Inflecto.singularize(base_name)}_#{attribute_name}"
            end
          end

          private

          def exclude?(base_name, attribute_name)
            if f_keys = foreign_keys.fetch(base_name, false)
              f_keys.include?(attribute_name)
            else
              false
            end
          end
        end # NaturalJoin
    end # Mapping
  end # Schema
end # Ramom
