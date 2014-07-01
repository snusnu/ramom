# encoding: utf-8

module Ramom
  class Database

    include Concord.new(:commands, :reader)

    def self.setup(commands, reader, options)
      new(commands.facade(self, options), reader)
    end

    attr_reader :schema

    def initialize(commands, reader)
      super
      @schema = reader.schema
    end

    def one(name, *args, &block)
      reader.one(name, *args, &block)
    end

    def read(name, *args)
      reader.read(name, *args)
    end

    def write(name, *args)
      commands.call(self, backend, name, *args)
    end

    def read_relation(name, *args, &block)
      @schema.call(name, *args, &block)
    end
  end # Database
end # Ramom
