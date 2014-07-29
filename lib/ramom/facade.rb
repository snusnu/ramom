# encoding: utf-8

module Ramom

  class Facade

    def self.build(commands, queries)
      new(commands.registry, queries.registry)
    end

    include Concord.new(:commands, :queries)

    def read(name, *args, &block)
      queries.fetch(name).call(*args, &block)
    end

    def write(name, *args, &block)
      commands.fetch(name).call(*args, &block)
    end
  end # Facade
end # Ramom
