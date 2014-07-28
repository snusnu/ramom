# encoding: utf-8

module Ramom
  class Writer

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

  end # Writer
end # Ramom
