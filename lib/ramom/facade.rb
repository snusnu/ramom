# encoding: utf-8

module Ramom

  class Facade

    def self.build(commands, queries, env)
      new(commands.registry, queries.registry, env)
    end

    include Concord.new(:commands, :queries, :env)

    attr_reader :database
    attr_reader :schema

    alias_method :db, :database

    def initialize(*)
      super
      @database = env.database
      @schema   = @database.schema
    end

    def read(name, *args, &block)
      queries.fetch(name).call(*args, &block)
    end

    def write(name, *args, &block)
      commands.fetch(name).call(*args, &block)
    end

    def rel(name, *args, &block)
      schema.rel(name, *args, &block)
    end
  end # Facade
end # Ramom
