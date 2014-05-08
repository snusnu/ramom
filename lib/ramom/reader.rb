# encoding: utf-8

module Ramom
  class Reader

    class Loader
      include Concord.new(:relation, :mapper)
      include Enumerable

      def each(&block)
        return to_enum unless block
        relation.each { |tuple| yield(mapper.load(tuple)) }
        self
      end

      def one(&block)
        mapper.load(relation.one(&block))
      end

      def sort
        new(relation.sort)
      end

      def sort_by(&block)
        new(relation.sort_by(&block))
      end

      private

      def new(new_relation)
        self.class.new(new_relation, mapper)
      end
    end # Loader

    include Concord.new(:schema, :mapping)

    def self.build(adapter, schema_definition, mapping)
      new(Schema.build(adapter, schema_definition), mapping)
    end

    def read(name, *args)
      Loader.new(relation(name, *args), mapping[name])
    end

    def one(name, *args, &block)
      Loader.new(relation(name, *args), mapping[name]).sort.one(&block)
    end

    private

    def relation(name, *args)
      schema.__send__(name, *args).optimize
    end
  end # Reader
end # Ramom
