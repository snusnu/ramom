# encoding: utf-8

module Ramom
  class Relation

    class Builder

      include AbstractType
      include Procto.call

      abstract_method :name
      abstract_method :header

      private :name
      private :header

      def call
        Axiom::Relation::Base.new(name, header)
      end
    end # Builder
  end # Relation
end # Ramom
