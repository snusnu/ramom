# encoding: utf-8

module Ramom
  module DM
    class Database < Ramom::Database

      def self.build(schema_options, relation_registry)
        schema = Ramom::Schema.build(schema_options)
        writer = Writer.new(relation_registry)

        new(schema, writer)
      end

      def initialize(schema, writer)
        super(schema)
        @writer = writer
      end

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

      private

      attr_reader :writer

    end # Database
  end # DM
end # Ramom
