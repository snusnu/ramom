# encoding: utf-8

module Ramom
  class Schema < BasicObject
    class Definition
      class Resolver

        class Compiler
          include AbstractType
          include Concord.new(:relations, :container)
          include Procto.call

          abstract_method :call

          class Base < self
            def call
              relations = self.relations
              container.module_eval do
                relations.each do |(name, relation)|
                  define_method(name) { relation }
                end
              end
              container
            end
          end # Base

          class Virtual < self
            def call
              relations = self.relations
              container.module_eval do
                relations.each do |(name, relation)|
                  define_method(name, &relation.body)
                end
              end
              container
            end
          end # Virtual
        end # Compiler
      end # Resolver
    end # Definition
  end # Schema
end # Ramom
