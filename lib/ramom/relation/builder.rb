# encoding: utf-8

module Ramom
  module Relation

    class Builder

      include AbstractType
      include Procto.call

      abstract_method :name
      abstract_method :attributes
      abstract_method :keys
      abstract_method :name_generator

      def call
        Axiom::Relation::Base.new(name, header).rename(aliases)
      end

      private

      def header
        Axiom::Relation::Header.coerce(attributes, keys: keys)
      end

      def aliases
        attributes.each_with_object({}) { |(attr_name, _), h|
          aliased = name_generator.call(name, attr_name)
          h[attr_name] = aliased if attr_name != aliased
        }
      end

    end # Builder
  end # Relation
end # Ramom
