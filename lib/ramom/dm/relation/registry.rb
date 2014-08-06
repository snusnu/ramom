# encoding: utf-8

module Ramom
  module DM
    module Relation

      class Registry
        include Lupo.collection(:relations)

        def self.build(models, blacklist)
          new(models.each_with_object({}) { |model, h|
            h[model.storage_name.to_sym] = model unless blacklist.include?(model)
          })
        end

        def [](name)
          relations.fetch(name)
        end
      end # Registry
    end # Relation
  end # DM
end # Ramom
