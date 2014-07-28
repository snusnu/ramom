# encoding: utf-8

module Ramom

  class Reader
    include Concord::Public.new(:relation, :dresser)
    include Enumerable

    def one(&block)
      dress(relation.one(&block))
    end

    def each(&block)
      return to_enum unless block
      relation.each { |tuple| yield(dress(tuple)) }
      self
    end

    private

    def dress(tuple)
      dresser.call(tuple)
    end
  end # Reader
end # Ramom
