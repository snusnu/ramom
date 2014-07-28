# encoding: utf-8

module Ramom

  class Facade
    include Concord.new(:commands, :queries, :environment)

    def read(name, *args, &block)
      queries.fetch(name).call(environment, *args, &block)
    end

    def write(name, *args, &block)
      commands.fetch(name).call(environment, *args, &block)
    end
  end # Facade
end # Ramom
