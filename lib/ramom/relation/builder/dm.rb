# encoding: utf-8

module Ramom
  class Relation
    class Builder

      class DM < self

        include Concord.new(:model)

        def initialize(model)
          super
          @properties = model.properties
        end

        private

        attr_reader :properties

        def name
          model.storage_name(:default).to_sym
        end

        def header
          properties.map { |p| [p.field, p.primitive, {keys: unique_indexes}] }
        end

        def unique_indexes
          properties.unique_indexes.values
        end

      end # DM
    end # Builder
  end # Relation
end # Ramom
