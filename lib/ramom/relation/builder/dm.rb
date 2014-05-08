# encoding: utf-8

module Ramom
  class Relation
    class Builder

      class DM < self

        include Concord.new(:model)

        private

        def name
          model.storage_name(:default).to_sym
        end

        def header
          model.properties.map { |p| [p.field, p.primitive] }
        end
      end # DM
    end # Builder
  end # Relation
end # Ramom
