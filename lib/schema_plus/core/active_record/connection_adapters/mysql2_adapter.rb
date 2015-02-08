module SchemaPlus
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module Mysql2Adapter

          def self.prepended(base)
            SchemaMonkey.include_once ::ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter, SchemaPlus::Core::ActiveRecord::ConnectionAdapters::SchemaStatements::Column
            SchemaMonkey.include_once ::ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter, SchemaPlus::Core::ActiveRecord::ConnectionAdapters::SchemaStatements::Reference
            SchemaMonkey.include_once ::ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter, SchemaPlus::Core::ActiveRecord::ConnectionAdapters::SchemaStatements::Index
          end

          def indexes(table_name, query_name=nil)
            SchemaMonkey::Middleware::Query::Indexes.start(connection: self, table_name: table_name, query_name: query_name, index_definitions: []) { |env|
              env.index_definitions += super env.table_name, env.query_name
            }.index_definitions
          end

          def tables(query_name=nil, database=nil, like=nil)
            SchemaMonkey::Middleware::Query::Tables.start(connection: self, query_name: query_name, database: database, like: like, tables: []) { |env|
              env.tables += super env.query_name, env.database, env.like
            }.tables
          end

          def select_rows(sql, name=nil, binds=[])
            SchemaMonkey::Middleware::Query::Exec.start(connection: self, sql: sql, name: name, binds: binds) { |env|
              env.result = super env.sql, env.name, env.binds
            }.result
          end

          def exec_query(sql, name='SQL', binds=[])
            SchemaMonkey::Middleware::Query::Exec.start(connection: self, sql: sql, name: name, binds: binds) { |env|
              env.result = super env.sql, env.name, env.binds
            }.result
          end

          alias exec_without_stmt exec_query

          def exec_insert(sql, name, binds, pk = nil, sequence_name = nil)
            SchemaMonkey::Middleware::Query::Exec.start(connection: self, sql: sql, name: name, binds: binds) { |env|
              env.result = super env.sql, env.name, env.binds, pk, sequence_name
            }.result
          end

          def exec_delete(sql, name, binds)
            SchemaMonkey::Middleware::Query::Exec.start(connection: self, sql: sql, name: name, binds: binds) { |env|
              env.result = super env.sql, env.name, env.binds
            }.result
          end

          alias :exec_update :exec_delete

        end
      end
    end
  end
end
