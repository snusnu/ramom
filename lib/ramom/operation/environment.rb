# encoding: utf-8

module Ramom
  module Operation

    class Environment

      include Concord.new(:services)

      def initialize(services = EMPTY_HASH)
        super(services.dup)
      end

      def register(other_services)
        self.class.new(services.merge(other_services))
      end

      private

      def method_missing(name, *args, &block)
        return super unless services.key?(name)
        services[name]
      end

      def respond_to_missing?(name, include_private = false)
        super || services.key?(name)
      end
    end # Environment
  end # Operation
end # Ramom
