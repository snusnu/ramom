# encoding: utf-8

module Ramom
  module Naming

    class NaturalJoin
      include Concord.new(:fk_attributes)

      def call(base_name, attribute_name)
        return attribute_name if fk_attribute?(base_name, attribute_name)
        :"#{prefix(base_name)}#{attribute_name}"
      end

      private

      def fk_attribute?(base_name, attribute_name)
        fk_attributes.fetch(base_name, EMPTY_ARRAY).include?(attribute_name)
      end

      def prefix(name)
        name ? Inflecto.singularize(name.to_s) + separator(name) : EMPTY_STRING
      end

      def separator(name)
        name.empty? ? EMPTY_STRING : UNDERSCORE
      end
    end # NaturalJoin
  end # Naming
end # Ramom
