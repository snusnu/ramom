# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition

      class Context

        class Relation
          include Anima.new(:name, :visibility, :body)

          def external?
            visibility == :public
          end

          class Base < self
            include anima.add(:adapter)
            include Anima::Update

            def gateway(adapter)
              relation = Axiom::Relation::Gateway.new(adapter, body.call)
              update(body: ->() { relation })
            end

            def attr_names
              Set.new(body.call.header.map(&:name))
            end
          end # Base
        end # Relation

        DEFAULT_ATTRIBUTES = {
          base:           {},
          virtual:        {},
          fk_constraints: FKConstraint::Set.new
        }.freeze

        include Anima.new(:base, :virtual, :fk_constraints)

        def initialize(attributes = DEFAULT_ATTRIBUTES, &block)
          super(attributes.dup)
          call(&block) if block
        end

        def call(&block)
          instance_eval(&block)
          self
        end

        def base_relation(name, options, &block)
          base[name] = Relation::Base.new(
            name:       name,
            visibility: options.fetch(:visibility, :public),
            adapter:    options.fetch(:adapter),
            body:       block
          )
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
          virtual[name] = Relation.new(
            name:       name,
            visibility: visibility,
            body:       block
          )
        end
      end # Context
    end # Definition
  end # Schema
end # Ramom
