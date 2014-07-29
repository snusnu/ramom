# encoding: utf-8

module Ramom
  module Operation

    class Registry
      include Concord.new(:dressers, :environment, :operation)
      include Lupo.enumerable(:operations)

      def initialize(*args)
        super
        @operations = {}
      end

      def register(name, options, &block)
        dresser = dressers[options.fetch(:dresser)]

        op = operation.new(name, environment, dresser)
        (class << op; self end).class_eval {
          define_method(:call, &block)
        }

        @operations[name] = op
      end

      def fetch(*args, &block)
        @operations.fetch(*args, &block)
      end
    end # Registry
  end # Operation
end # Ramom
