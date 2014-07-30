# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      class Builder

        class Context

          class Relation
            include Concord::Public.new(:name, :visibility, :body)
          end # Relation

          include Concord::Public.new(:base, :fk_constraints, :virtual)

          def self.call(base, fk_constraints, virtual, &block)
            new(base.dup, fk_constraints, virtual.dup).call(&block)
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
            fk_constraints.add(source, target, mapping)
          end

          def internal(name, &block)
            relation(name, :private, &block)
          end

          def external(name, &block)
            relation(name, :public, &block)
          end

          def relation(name, visibility, &block)
            virtual[name] = Relation.new(name, visibility, block)
          end
        end # Context

        DEFAULT_OPTIONS = {
          base:           EMPTY_HASH,
          virtual:        EMPTY_HASH,
          fk_constraints: FKConstraint::Set.new
        }.freeze

        include Anima.new(:base, :fk_constraints, :virtual, :block)

        def self.call(options, &block)
          new(DEFAULT_OPTIONS.merge(options).merge!(block: block)).call
        end

        def call
          Definition.new(Context.call(base, fk_constraints, virtual, &block))
        end
      end # Builder
    end # Definition
  end # Schema
end # Ramom
