# encoding: utf-8

module Ramom
  module DM

    def self.schema_definition(models, &block)
      Schema::Definition::Builder.call(models, &block)
    end

    def self.environment(options)
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
