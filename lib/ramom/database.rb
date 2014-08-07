# encoding: utf-8

module Ramom
  class Database
    include Concord::Public.new(:schema)

    def insert(relation, tuples)
      relation.insert(relation, tuples)
    end

    def update(relation, tuples)
      relation.update(relation, tuples)
    end

    def delete(relation, tuples)
      relation.delete(relation, tuples)
    end

    def relation(name, *args)
      schema.call(name, *args)
    end

    alias_method :rel, :relation

    def fk_wrapped_rel(name, *args)
      schema.fk_wrapped_rel(name, *args)
    end

  end # Database
end # Ramom
