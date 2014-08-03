# encoding: utf-8

module Ramom
  module Operation

    class Registrar < Module

      module Callsite
        def registrar(*args)
          Registrar.build(self, *args)
        end
      end

      module ClassMethods
        def register(name, options, &block)
          registry.register(name, options, &block)
        end
      end # ClassMethods

      include Concord.new(:registry, :kind)

      def self.build(kind, environment, operation)
        new(Registry.new(environment, operation), kind)
      end

      private

      def included(host)
        host.instance_exec(registry, kind) do |registry, kind|
          define_singleton_method(:registry) { registry }
          extend(ClassMethods)
          include(kind)
        end
      end
    end # Registrar
  end # Operation
end # Ramom
