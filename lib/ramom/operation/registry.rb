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
        op      = operation.new(name, environment, dresser)

        # We basically use the op instance as the context
        # to evaluate the function given as &block. This
        # is probably a bit unusual for typical OO, it is
        # however perfectly valid ruby, and simply another
        # way of doing (prototype oriented) functional OOP

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
