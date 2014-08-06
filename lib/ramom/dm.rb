# encoding: utf-8

module Ramom
  module DM

    REJECT_FOR_SCHEMA_BUILDER = [:models, :dressers].freeze

    def self.relation_registry(models, mapping = EMPTY_HASH)
      Relation::Registry.build(models, mapping)
    end

    def self.schema_definition_context(relation_registry, &block)
      Schema::Definition::Context::Builder.call(relation_registry, &block)
    end

    def self.schema_definition(relation_registry, &block)
      context = schema_definition_context(relation_registry, &block)
      Ramom::Schema::Definition.new(context)
    end

    def self.environment(options)
      schema_options = options.reject { |k|
        REJECT_FOR_SCHEMA_BUILDER.include?(k)
      }

      Operation::Environment.new(
        database: Database.build(schema_options, options.fetch(:models)),
        dressers: options.fetch(:dressers)
      )
    end
  end # DM
end # Ramom

require 'ramom/dm/relation/builder'
require 'ramom/dm/relation/registry'
require 'ramom/dm/schema/definition/context/builder'
require 'ramom/dm/writer'
require 'ramom/dm/database'
