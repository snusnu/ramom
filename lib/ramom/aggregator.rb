# encoding: utf-8

module Ramom

  class Aggregator
    include Concord.new(:relation)

    def count(attribute = nil)
      relation.summarize { |r|
        r.add(:count, r.send(attribute || key_attribute).count)
      }.one[:count]
    end

    private

    def key_attribute
      relation.header.keys.to_a.flatten.first.name
    end
  end # Aggregator
end # Ramom
