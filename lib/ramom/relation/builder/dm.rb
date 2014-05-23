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

        def name
          model.storage_name(:default).to_sym
        end

        def header
          @properties.map { |p| [p.field.to_sym, p.primitive, {keys: keys}] }
        end

        def keys
          @properties.unique_indexes.values
        end

      end # DM
    end # Builder
  end # Relation
end # Ramom
