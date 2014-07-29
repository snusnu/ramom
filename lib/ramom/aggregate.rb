# encoding: utf-8

module Ramom

  class Aggregate
    include Concord.new(:relation)

    def count(attribute = nil)
      relation.summarize { |r|
        r.add(:count, r.send(attribute || required_attribute).count)
      }.one[:count]
    end

    private

    def required_attribute
      # we cannot rely on the presence of keys, therefore
      # we just take an arbitrary required attribute
      #
      # find out if it's really necessary to find a required
      # attribute. Afaik, RA doesn't support NULL anyways
      relation.header.to_a.detect { |a| a.required? }.name
    end
  end # Aggregate
end # Ramom
