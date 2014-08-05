# encoding: utf-8

module Ramom
  module DM
    module Schema
      module Definition
        module Context

          class Builder

            DM_ADAPTER_KEY = 'adapter'.freeze

            def self.call(models, &block)
              new(models).call(&block)
            end

            def self.adapter(model)
              model.repository.adapter.options[DM_ADAPTER_KEY].to_sym
            end

            include Concord.new(:models, :context)

            public :context

            # This object mutates the injected +context+
            def initialize(_, context = Ramom::Schema::Definition::Context.new)
              super
              infer_base_relations
            end

            def call(&block)
              context.call(&block)
            end

            private

            def infer_base_relations
              models.each_with_object({}) { |model, h|

                fk_attributes = Set.new
                with_fk_constraints(model) do |source_name, target_name, mapping|
                  context.fk_constraint(source_name, target_name, mapping)
                  fk_attributes.merge(mapping.keys)
                end

                name           = relation_name(model)
                name_generator = Naming::NaturalJoin.new(name => fk_attributes)
                base_relation  = Relation::Builder.call(model, name_generator)

                options = {adapter: self.class.adapter(model), visibility: :public}

                context.base_relation(name, options) { base_relation }
              }
            end

            def with_fk_constraints(model)
              model.relationships.each do |relationship|
                if relationship.respond_to?(:required?) # M:1
                  source_name = relation_name(relationship.source_model)
                  target_name = relation_name(relationship.target_model)
                  source_key  = key_attributes(relationship.source_key)
                  target_key  = key_attributes(relationship.target_key)
                  mapping     = Hash[source_key.zip(target_key)]

                  yield(source_name, target_name, mapping)
                end
              end
            end

            def relation_name(model)
              model.storage_name(:default).to_sym
            end

            def key_attributes(key)
              key.map { |property| property.field.to_sym }
            end
          end # Builder
        end # Context
      end # Definition
    end # Schema
  end # DM
end # Ramom
