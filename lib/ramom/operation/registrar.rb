# encoding: utf-8

module Ramom
  class Operation

    class Registrar < Module

      module ClassMethods
        def register(name, options)
          registry.register(name, options, self)
        end
      end # ClassMethods

      include Concord.new(:registry)

      def self.build(dressers, operations = EMPTY_HASH)
        new(Registry.new(dressers, operations.dup))
      end

      private

      def included(host)
        host.instance_exec(registry) do |registry|
          define_singleton_method(:registry) { registry }
          extend(ClassMethods)
        end
      end
    end # Registrar
  end # Operation
end # Ramom
