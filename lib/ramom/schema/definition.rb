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

        include Concord.new(:schema_definition)
        include Adamantium::Flat
        include Procto.call

        def initialize(*)
          super
          @base_relations    = schema_definition.base_relations
          @virtual_relations = schema_definition.virtual_relations
        end

        def call
          relations = Module.new
          relations = Compiler::Base.call(base_relations, relations)
          relations = Compiler::Virtual.call(@virtual_relations, relations)

          Class.new(Schema) { include(relations) }
        end

        private

        def base_relations
          @base_relations.each_with_object({}) { |(name, relation), relations|
            relations[name] = base_relation(name, relation)
          }
        end

        def base_relation(_name, relation)
          relation # This is a NOOP because I use DM1 base relations
        end
      end # Resolver

      include Concord.new(:context)

      attr_reader :base_relations
      attr_reader :virtual_relations

      def initialize(*)
        super
        @base_relations    = context.base
        @virtual_relations = context.virtual
      end
    end # Definition
  end # Schema
end # Ramom
