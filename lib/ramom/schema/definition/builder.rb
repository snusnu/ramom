# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      class Builder

        class Context

          class Future
            include Concord::Public.new(:name, :body)
          end # Future

          include Concord::Public.new(:base, :virtual)

          def self.call(base = EMPTY_HASH, virtual = EMPTY_HASH, &block)
            new(base.dup, virtual.dup).call(&block)
          end

          def call(&block)
            instance_eval(&block)
            self
          end

          private

          def base_relation(name, &block)
            raise NotImplementedError
          end

          def relation(name, &block)
            virtual[name] = Future.new(name, block)
          end
        end # Context

        include Adamantium::Flat
        include Concord.new(:base, :virtual, :block)
        include Procto.call

        def call
          Definition.new(Context.call(base, virtual, &block))
        end
      end # Builder
    end # Definition
  end # Schema
end # Ramom
