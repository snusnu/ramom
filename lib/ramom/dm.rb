# encoding: utf-8

module Ramom
  module DM

    REJECT_FOR_SCHEMA_BUILDER = [:models, :dressers].freeze

    def self.schema_definition(models, &block)
      Schema::Definition::Builder.call(models, &block)
    end

    def self.environment(options)
      schema = Ramom::Schema.build(options.reject { |k|
        REJECT_FOR_SCHEMA_BUILDER.include?(k)
      })

      writer = Ramom::DM::Writer.build(options.fetch(:models))

      Operation::Environment.new(
        database: Ramom::Database.new(schema, writer),
        dressers: options.fetch(:dressers)
      )
    end

  end # DM
end # Ramom

require 'ramom/dm/relation/builder'
require 'ramom/dm/schema/definition/builder'
require 'ramom/dm/writer'
