# encoding: utf-8

module Ramom
  class Database
    class Command

      class Environment
        include Anima.new(:database, :backend, :dressers)
      end # Environment
    end # Command
  end # Database
end # Ramom
