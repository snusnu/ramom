# encoding: utf-8

module Ramom
  class Schema < BasicObject

    class FKConstraint

      class Set

        def self.fk_attributes(fkc_set)
          fkc_set.reduce(::Set.new) { |set, fkc| set + fkc.source_attributes }
        end

        include Lupo.collection(:constraints)

        def initialize(constraints = FK_C_HASH.dup)
          super
        end

        def add(source, target, mapping)
          constraints[source] << FKConstraint.new(source, target, mapping)
        end

        def fetch(source)
          constraints.fetch(source, EMPTY)
        end

        def source_attributes
          constraints.reduce({}) { |h, (source_name, fkc_set)|
            h.merge(source_name => self.class.fk_attributes(fkc_set))
          }
        end

        def empty?
          constraints.empty?
        end

        EMPTY = new.freeze # an empty null object instance

      end # Set

      include Concord::Public.new(:source, :target, :mapping)

      def source_attributes
        mapping.keys
      end

      def target_attributes
        mapping.values
      end
    end # FKConstraint
  end # Schema
end # Ramom
