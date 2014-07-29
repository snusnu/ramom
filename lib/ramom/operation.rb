# encoding: utf-8

module Ramom

  module Operation

    include Concord.new(:name, :environment, :dresser)
    include AbstractType

    abstract_method :call

    def initialize(name, environment, dresser)
      super
      @db = environment.database
    end

    private

    attr_reader :db

    def dress(attributes)
      dresser.call(attributes)
    end

    def success(data)
      Result::Success.new(data)
    end

    def failure(data)
      Result::Failure.new(data)
    end
  end # Operation
end # Ramom
