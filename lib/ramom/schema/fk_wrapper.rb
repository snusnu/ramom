# encoding: utf-8

module Ramom
  class Schema < BasicObject

    class FKWrapper
      include Concord.new(:name, :relation, :fkc_set)

      def self.call(name, relation, fk_constraints)
        unless base_relation?(relation)
          msg = "#{name.inspect} is no base relation"
          raise ArgumentError.new(msg)
        end
        fkc_set = fk_constraints.fetch(name)
        return relation if fkc_set.empty?
        new(name, relation, fkc_set).call
      end

      def self.base_relation?(rel)
        rel.is_a?(Axiom::Relation::Gateway) || rel.is_a?(Axiom::Relation::Base)
      end
      private_class_method :base_relation?

      def call
        fkc_set.reduce(relation) { |rel, fk|
          rel.wrap(Inflecto.singularize(fk.target.to_s).to_sym => fk.source_attributes)
        }
      end
    end # FKWrapper
  end # Schema
end # Ramom
