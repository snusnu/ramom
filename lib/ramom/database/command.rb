# encoding: utf-8

module Ramom
  class Database

    class Command

      include Concord.new(:environment, :output)
      include AbstractType

      abstract_method :call

      def self.register(name, options, registry)
        registry.register(name, options, self)
      end

      def self.call(environment, output, *args)
        new(environment, output).call(*args)
      end

      def initialize(environment, output)
        super
        @database = environment.database
        @backend  = environment.backend
        @dressers = environment.dressers
      end

      private

      attr_reader :database
      attr_reader :backend
      attr_reader :dressers

      def one(relation_name, attributes)
        model = backend[relation_name]
        model.get(*keys(attributes, model))
      end

      def update(record, attributes)
        if record && record.update(attributes)
          success(dress(output, record.attributes))
        else
          failure(attributes)
        end
      end

      def delete(record, attributes)
        update(record, attributes.fetch(:stamps), output)
      end

      def respond(input, record)
        if record && record.saved?
          success(dress(output, record.attributes))
        else
          failure(input)
        end
      end

      def transaction(repository = :default, &block)
        backend.transaction(repository, &block)
      end

      def keys(attributes, model)
        attributes.values_at(model.key)
      end

      def dress(name, attributes)
        dressers.fetch(name).load(attributes)
      end

      def success(data)
        Response.success(data)
      end

      def failure(data)
        Response.failure(data)
      end
    end # Command
  end # Database
end # Ramom
