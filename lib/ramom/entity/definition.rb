# encoding: utf-8

module Ramom
  class Entity

    class Definition

      include Concord.new(:entity_name, :default_options, :header)

      public :entity_name
      public :default_options

      def self.build(entity_name, default_options = EMPTY_HASH, header = EMPTY_ARRAY, &block)
        instance = new(entity_name, default_options, header)
        instance.instance_eval(&block) if block
        instance
      end

      def self.new(entity_name, default_options, header)
        super(entity_name, default_options.dup, header.dup)
      end

      def map(name, *args)
        header << Attribute::Primitive.build(name, default_options, args)
      end

      def wrap(name, options = EMPTY_HASH, &block)
        header << Attribute::Entity.build(name, options, default_options, block)
      end

      def group(name, options = EMPTY_HASH, &block)
        header << Attribute::Collection.build(name, options, default_options, block)
      end

      def attribute_nodes(environment, builder)
        header.map { |attribute| attribute.node(environment, builder) }
      end

      def attribute_names
        header.map(&:name)
      end

      def defaults
        header.each_with_object({}) { |attribute, hash|
          if attribute.default_value?
            hash[attribute.old_key] = attribute.default_value
          end
        }
      end

    end # Definition
  end # Entity
end # Ramom
