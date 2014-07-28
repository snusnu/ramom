# encoding: utf-8

module Ramom
  class Operation

    class Proxy
      include Anima.new(:name, :operation, :dresser)

      def call(environment, *args)
        operation.call(environment, dresser, *args)
      end
    end

    class Registry
      include Concord.new(:dressers, :operations)
      include Lupo.enumerable(:operations)

      def register(name, options, operation)
        operations[name] = Proxy.new(
          name:      name,
          operation: operation,
          dresser:   dressers[options.fetch(:dresser)]
        )
      end

      def fetch(*args, &block)
        operations.fetch(*args, &block)
      end
    end # Registry
  end # Operation
end # Ramom
