# encoding: utf-8

module Ramom
  class Writer

    class DM < self
      include Concord::Public.new(:models)

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

      private

      def each_tuple(relation_name, tuples)
        model = models[relation_name]
        Array(tuples).each_with_object([]) { |tuple, array|
          yield(model, tuple, array)
        }
      end

      def keys(tuple, model)
        tuple.values_at(model.key)
      end
    end

    include AbstractType

    def insert(relation_name, tuples)
      raise NotImplementedError
    end

    def update(relation_name, tuples)
      raise NotImplementedError
    end

    def delete(relation_name, tuples)
      raise NotImplementedError
    end

  end # Reader
end # Ramom
