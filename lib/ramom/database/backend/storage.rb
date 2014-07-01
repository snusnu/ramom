require 'data_objects'
require 'do_postgres'
require 'dm-migrations'

module Ramom
  class Database
    module Backend

      class Storage

        class Environment

          attr_reader :config

          def initialize(config)
            @config = config
          end

          def create_all
            with_local_repositories { |config| create(config) }
          end

          def drop_all
            with_local_repositories { |config| drop(config) }
          end

          def create(config)
            new_storage(config).create
          end

          def drop(config)
            new_storage(config).drop
          end

          def auto_migrate!(config)
            new_storage(config).auto_migrate!
          end

          def auto_upgrade!(config)
            new_storage(config).auto_upgrade!
          end

          def [](name)
            config[name]
          end

          private

          LOCAL_HOSTS = %w[ 127.0.0.1 localhost ].freeze

          def with_local_repositories
            config.each_value do |config|
              host = config['host']
              if host.empty? || LOCAL_HOSTS.include?(host)
                yield(config)
              else
                puts "SKIPPED: #{config['database']} is on a remote host."
              end
            end
          end

          def new_storage(config)
            Storage.new(config)
          end

        end # Environment

        def self.setup(config)
          new(config).setup
        end

        def self.auto_migrate!(config)
          new(config).auto_migrate!
        end

        CONNECTION_URI    = 'postgres://localhost/postgres'.freeze
        NAMING_CONVENTION = DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule

        attr_reader :config

        attr_reader :adapter
        attr_reader :database
        attr_reader :username
        attr_reader :password
        attr_reader :charset

        def initialize(config)
          @config   = config
          @adapter  = config.fetch('adapter')
          @database = config.fetch('database')
          @username = config.fetch('username')
          @password = config.fetch('password')
          @charset  = config.fetch('charset', 'utf8')
        end

        def setup
          DataMapper.logger = DataMapper::Logger.new($stdout, :debug) if ::ENV['LOG']
          adapter = DataMapper.setup(:default, config)
          adapter.resource_naming_convention = NAMING_CONVENTION
          DataMapper.finalize
        end

        def create
          if _create
            puts "[datamapper] Created database '#{database}'"
          end
        end

        def drop
          if _drop
            puts "[datamapper] Dropped database '#{database}'"
          end
        end

        def auto_migrate!
          setup and DataMapper.auto_migrate!
        end

        def auto_upgrade!
          setup and DataMapper.auto_upgrade!
        end

        private

        def _create
          execute "CREATE DATABASE #{database.inspect} OWNER=#{username.inspect}"
        end

        def _drop
          execute <<-SQL
            UPDATE pg_catalog.pg_database
            SET datallowconn=false
            WHERE datname='#{database}'
          SQL

          read <<-SQL
            SELECT pg_terminate_backend(pg_stat_activity.pid)
            FROM pg_stat_activity
            WHERE datname = '#{database}'
              AND pid <> pg_backend_pid()
          SQL

          execute "DROP DATABASE IF EXISTS #{database.inspect}"
        end

        def read(statement, *bind_values)
          with_connection do |connection|
            command = connection.create_command(statement)
            command.execute_reader(*bind_values)
          end
        end

        def execute(statement, *bind_values)
          with_connection do |connection|
            command = connection.create_command(statement)
            command.execute_non_query(*bind_values)
          end
        end

        def with_connection
          yield connection = DataObjects::Connection.new(CONNECTION_URI)
        ensure
          connection.close
        end

      end # Storage
    end # Backend
  end # Database
end # Ramom
