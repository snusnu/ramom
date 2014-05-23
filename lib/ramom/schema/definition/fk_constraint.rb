# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition

      class FKConstraint

        class Set
          include Lupo.collection(:constraints)

          def initialize(constraints = FK_C_HASH.dup)
            super
          end

          def add(source, target, mapping)
            constraints[source] << FKConstraint.new(source, target, mapping)
          end

          def [](source_name)
            constraints[source_name]
          end

          def source_attributes
            constraints.reduce({}) { |hash, (source_name, fkc_set)|
              hash.merge(source_name => fk_attributes(fkc_set))
            }
          end

          def fk_attributes(fkc_set)
            fkc_set.reduce(::Set.new) { |set, fkc| set + fkc.source_attributes }
          end
        end # Set

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
