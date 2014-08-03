# encoding: utf-8

module Ramom
  module DM

    def self.schema_definition(models, &block)
      Schema::Definition::Builder.call(models, &block)
    end

    def self.schema_definition_options(models)
      dm_definition = Schema::Definition::Builder.call(models)
      {
        base:           dm_definition[:base_relations],
        fk_constraints: dm_definition[:fk_constraints]
      }
    end

    def self.operation_environment(options)
      schema = Ramom::Schema.build(options.reject { |k| k.equal?(:models) })
      writer = Ramom::DM::Writer.build(options.fetch(:models))

      Operation::Environment.new(
        database: Ramom::Database.new(schema, writer)
      )
    end

  end # DM
end # Ramom

require 'ramom/dm/relation/builder'
require 'ramom/dm/schema/definition/builder'
require 'ramom/dm/writer'
