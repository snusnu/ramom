# encoding: utf-8

module Ramom
  class Database
    module Backend

      class DM

        class Mapping
          include Concord.new(:mapping)

          def initialize(mapping = EMPTY_HASH, &block)
            super(mapping.dup)
            instance_eval(&block) if block
          end

          def call(model)
            [relation_name(model), model]
          end

          private

          def map(relation_name, model)
            mapping[model.name] = relation_name
          end

          def relation_name(model)
            mapping.fetch(model.name, model.storage_name.to_sym)
          end
        end # Mapping

        include Concord.new(:relations)

        def self.build(models, &block)
          mapping = Mapping.new(&block)
          new(models.each_with_object({}) { |model, hash|
            relation_name, mapped_model = mapping.call(model)
            hash[relation_name] = mapped_model
          })
        end

        def [](name)
          relations.fetch(name)
        end

        def transaction(repository = :default, &block)
          DataMapper.repository(repository).transaction.commit(&block)
        end
      end # DM
    end # Backend
  end # Database
end # Ramom
