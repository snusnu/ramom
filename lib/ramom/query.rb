# encoding: utf-8

module Ramom

  module Query

    extend  Operation::Registrar::Callsite
    include Operation

    def one(relation, &block)
      read(relation).one(&block)
    end

    def read(relation)
      Reader.new(relation, dresser)
    end

    def relation(name, *args, &block)
      db.relation(name, *args, &block)
    end

    alias_method :rel, :relation

  end # Query
end # Ramom
