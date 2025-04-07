# frozen_string_literal: true

require 'pg'
require 'overpass_parser/sql_dialect/postgres'

class PostgresOsm2pgsql
  def initialize
    
    @@con = PG.connect(ENV['DATABASE_URL'])
    @@con.query(File.read(File.dirname(__FILE__) + '/view.sql'))
    @dialect = OverpassParser::SqlDialect::Postgres.new(postgres_escape_literal: ->(s) { @@con.escape_literal(s) })
  end

  def exec(query)
    request = OverpassParser.parse(query)
    sql = request.to_sql(@dialect)
    puts sql
    result = @@con.exec(sql)
    [sql, result.collect { |row| row['j'].gsub('+00:00', 'Z') }]
  end
end
