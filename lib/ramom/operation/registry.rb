# encoding: utf-8

module Ramom
  module Operation

    class Registry
      include Concord.new(:environment, :operation)
      include Lupo.enumerable(:operations)

      def initialize(*args)
        super
        @dressers   = environment.dressers
        @operations = {}
      end

      def register(name, options, &block)
        op = operation.new(name, environment, dresser(options))

        # We basically use the op instance as the context
        # to evaluate the function given as &block. This
        # is probably a bit unusual for typical OO, it is
        # however perfectly valid ruby, and simply another
        # way of doing (prototype oriented) functional OOP
        #
        # Since this code gets executed ONCE at application
        # boot time, none of the common performance overhead
        # concerns should apply.

        op.define_singleton_method(:call, &block)

        @operations[name] = op
      end

      def fetch(*args, &block)
        @operations.fetch(*args, &block)
      end

      private

      def dresser(options)
        @dressers[options.fetch(:dresser)]
      end
    end # Registry
  end # Operation
end # Ramom
