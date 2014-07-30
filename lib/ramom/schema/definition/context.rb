# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition

      class Context

        class Relation
          include Concord::Public.new(:name, :visibility, :body)
        end # Relation

        include Anima.new(:base, :virtual, :fk_constraints)

        def initialize(attributes, &block)
          super(attributes.dup)
          instance_eval(&block)
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
    end # Definition
  end # Schema
end # Ramom
