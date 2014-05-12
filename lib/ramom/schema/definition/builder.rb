# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      class Builder

        class Context

          class Future
            include Concord::Public.new(:name, :visibility, :body)
          end # Future

          class FKConstraint
            include Concord::Public.new(:source, :target, :mapping)

            def source_attributes
              mapping.keys
            end

            def target_attributes
              mapping.values
            end
          end # FKConstraint

          include Concord::Public.new(:base, :virtual, :fk_constraints)

          def self.call(base = EMPTY_HASH, virtual = EMPTY_HASH, fk_constraints = EMPTY_HASH, &block)
            new(base.dup, virtual.dup, fk_constraints.dup).call(&block)
          end

          def call(&block)
            instance_eval(&block)
            self
          end

          private

          def base_relation(name, &block)
            raise NotImplementedError
          end

          def fk_constraint(source, target, mapping)
            fk_constraints[source] = FKConstraint.new(source, target, mapping)
          end

          def internal(name, &block)
            relation(name, :private, &block)
          end

          def external(name, &block)
            relation(name, :public, &block)
          end

          def relation(name, visibility, &block)
            virtual[name] = Future.new(name, visibility, block)
          end
        end # Context

        include Anima.new(:base, :virtual, :fk_constraints, :block)
        include Procto.call

        def call
          Definition.new(Context.call(base, virtual, fk_constraints, &block))
        end
      end # Builder
    end # Definition
  end # Schema
end # Ramom
