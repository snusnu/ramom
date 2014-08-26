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

    def success(object)
      Orc::Result.success(object)
    end

    def failure(context, status = :failure)
      Orc::Result.failure(context, status)
    end
  end # Operation
end # Ramom
