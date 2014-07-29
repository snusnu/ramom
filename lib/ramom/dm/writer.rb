# encoding: utf-8

module Ramom
  module DM

    class Writer < Ramom::Writer

      class Backend

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

        def transaction(repository, &block)
          DataMapper.repository(repository).transaction.commit(&block)
        end
      end # Backend

      def self.build(models, &block)
        Backend.build(models, &block)
      end

      include Concord::Public.new(:backend)

      def insert(relation_name, tuples)
        each_tuple(relation_name, tuples) { |model, tuple, array|
          array << model.create(tuple)
        }
      end

      def update(relation_name, tuples)
        each_tuple(relation_name, tuples) { |model, tuple, array|
          if resource = model.get(*keys(tuple, model))
            array << resource.update!(tuple)
          else
            raise NotFound.new(tuple)
          end
        }
      end

      def delete(relation_name, tuples)
        each_tuple(relation_name, tuples) { |model, tuple, array|
          if resource = model.get(*keys(tuple, model))
            array << resource.destroy!
          else
            raise NotFound.new(tuple)
          end
        }
      end

      def transaction(repository = :default, &block)
        backend.transaction(repository, &block)
      end

      private

      def each_tuple(relation_name, tuples)
        model = backend[relation_name]
        Array(tuples).each_with_object([]) { |tuple, array|
          yield(model, tuple, array)
        }
      end

      def keys(tuple, model)
        tuple.values_at(model.key)
      end
    end # DM
  end # Writer
end # Ramom
