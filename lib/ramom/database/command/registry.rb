# encoding: utf-8

module Ramom
  class Database
    class Command

      class Registry

        class Entry
          include Anima.new(:handler, :output)

          def call(environment, *args)
            handler.call(environment, output, *args)
          end
        end

        include Lupo.collection(:commands)

        def initialize(commands = EMPTY_HASH)
          super(commands.dup)
        end

        def register(name, options, klass)
          commands[name] = Entry.new(
            handler: klass,
            output:  options.fetch(:output)
          )
        end

        def facade(database, options)
          Facade.new(database, options)
        end
      end # Registry
    end # Command
  end # Database
end # Ramom
