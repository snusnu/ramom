# encoding: utf-8

module Ramom
  class Database
    class Operation

      class Result

        include Concord::Public.new(:output)
        include AbstractType

        abstract_method :success?

        class Success < self
          def success?
            true
          end
        end # Success

        class Failure < self
          def success?
            false
          end
        end # Failure

      end # Result
    end # Operation
  end # Database
end # Ramom
