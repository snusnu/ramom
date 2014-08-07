# encoding: utf-8

module Ramom
  class Schema < BasicObject

    class FKWrapper
      include Concord.new(:name, :relation, :fkc_set)

      def self.call(name, relation, fk_constraints)
        fkc_set = fk_constraints.fetch(name)
        return relation if fkc_set.empty?
        new(name, relation, fkc_set).call
      end

      def call
        fkc_set.reduce(relation) { |rel, fk|
          rel.wrap(Inflecto.singularize(fk.target.to_s).to_sym => fk.source_attributes)
        }
      end
    end # FKWrapper
  end # Schema
end # Ramom
