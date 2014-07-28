# encoding: utf-8

module Ramom

  class Operation

    include Concord.new(:environment, :dresser)
    include AbstractType

    abstract_method :call

    def self.call(environment, dresser, *args, &block)
      new(environment, dresser).call(*args, &block)
    end

    def initialize(environment, dresser)
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
