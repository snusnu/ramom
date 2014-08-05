# encoding: utf-8

module Ramom
  module DM

    REJECT_FOR_SCHEMA_BUILDER = [:models, :dressers].freeze

    def self.schema_definition(models, &block)
      Ramom::Schema::Definition.new(schema_definition_context(models, &block))
    end

    def self.schema_definition_context(models, &block)
      Schema::Definition::Context::Builder.call(models, &block)
    end

    def self.environment(options, &block)
      schema = Ramom::Schema.build(options.reject { |k|
        REJECT_FOR_SCHEMA_BUILDER.include?(k)
      })

      writer = Writer.build(options.fetch(:models), &block)

      Operation::Environment.new(
        database: Database.new(schema, writer),
        dressers: options.fetch(:dressers)
      )
    end

  end # DM
end # Ramom

require 'ramom/dm/relation/builder'
require 'ramom/dm/schema/definition/context/builder'
require 'ramom/dm/writer'
require 'ramom/dm/database'
