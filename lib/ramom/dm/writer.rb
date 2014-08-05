# encoding: utf-8

module Ramom
  module DM

    class Writer

      def self.build(models, &block)
        Relation::Registry.build(models, &block)
      end

      include Concord::Public.new(:registry)

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
        DataMapper.repository(repository).transaction.commit(&block)
      end

      private

      def each_tuple(relation_name, tuples)
        model = registry[relation_name]
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
