# encoding: utf-8

module Ramom
  class Relation

    class Builder

      include AbstractType
      include Procto.call

      abstract_method :name
      abstract_method :header
      abstract_method :keys
      abstract_method :name_generator

      def call
        Axiom::Relation::Base.new(name, header).rename(aliases)
      end

      private

      def aliases
        header.each_with_object({}) { |(attr_name, _), hash|
          aliased = name_generator.call(name, attr_name)
          hash[attr_name] = aliased if attr_name != aliased
        }
      end

    end # Builder
  end # Relation
end # Ramom
