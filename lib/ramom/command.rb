# encoding: utf-8

module Ramom

  module Command

    extend  Operation::Registrar::Callsite
    include Operation

    def one(relation_name, attributes)
      model = backend[relation_name]
      model.get(*keys(attributes, model))
    end

    def create(input, record = nil, &block)
      record = block ? transaction(&block) : record
      if record && record.saved?
        success(dress(output, record.attributes))
      else
        failure(input)
      end
    end

    def update(record, attributes)
      if record && record.update(attributes)
        success(dress(output, record.attributes))
      else
        failure(attributes)
      end
    end

    def delete(record, attributes)
      update(record, attributes.fetch(:stamps), output)
    end

    def transaction(&block)
      backend.transaction(:default, &block)
    end

    def keys(attributes, model)
      attributes.values_at(model.key)
    end
  end # Command
end # Ramom
