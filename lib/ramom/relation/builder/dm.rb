# encoding: utf-8

module Ramom
  class Relation
    class Builder

      class DM < self

        include Concord.new(:model)

        def initialize(model, name_generator)
          super(model)
          @properties     = model.properties
          @name_generator = name_generator
        end

        private

        attr_reader :name_generator
        attr_reader :properties

        def name
          model.storage_name(:default).to_sym
        end

        def attributes
          properties.map { |p| [p.field.to_sym, p.primitive] }
        end

        def keys
          properties.unique_indexes.values.map { |cpk|
            cpk.map { |k| k.to_sym }
          }
        end

      end # DM
    end # Builder
  end # Relation
end # Ramom
