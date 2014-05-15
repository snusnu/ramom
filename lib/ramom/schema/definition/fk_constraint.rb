# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition

      class FKConstraint
        include Concord::Public.new(:source, :target, :mapping)

        def source_attributes
          mapping.keys
        end

        def target_attributes
          mapping.values
        end
      end # FKConstraint
    end # Definition
  end # Schema
end # Ramom
