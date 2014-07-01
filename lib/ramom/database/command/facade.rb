# encoding: utf-8

module Ramom
  class Database

    class Facade
      include Equalizer.new(:registry, :environment)

      def initialize(database, registry, options)
        @registry    = registry
        @environment = Command::Environment.new(
          database: database,
          backend:  options.fetch(:backend),
          dressers: options.fetch(:dressers)
        )
      end

      def call(name, *args)
        registry.fetch(name).call(environment, *args)
      end

      protected

      attr_reader :registry
      attr_reader :environment
    end # Facade
  end # Database
end # Ramom
