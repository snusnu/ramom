# encoding: utf-8

module Ramom
  class Entity

    class Registry
      include Concord.new(:entries)

      def [](name)
        entries.fetch(name)
      end
    end # Registry
  end # Entity
end # Ramom
