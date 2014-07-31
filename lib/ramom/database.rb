# encoding: utf-8

module Ramom
  class Database
    include Concord::Public.new(:schema, :writer)

    def transaction(repository = :default, &block)
      writer.transaction(repository, &block)
    end

    def insert(relation, tuples)
      writer.insert(relation, tuples)
    end

    def update(relation, tuples)
      writer.update(relation, tuples)
    end

    def delete(relation, tuples)
      writer.delete(relation, tuples)
    end

    def relation(name, *args)
      schema.call(name, *args)
    end

    alias_method :rel, :relation

    def fk_wrapped_rel(name)
      schema.fk_wrapped_rel(name)
    end

  end # Database
end # Ramom
