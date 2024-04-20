# frozen_string_literal: true

require 'pg'
require 'overpass_parser/sql_dialect/postgres'

class PostgresOsmosis
  def initialize
    @@con = PG.connect(ENV['DATABASE_URL'])
    @@con.query(File.read(__FILE__.gsub(/\.rb$/, '.sql')))
    @dialect = OverpassParser::SqlDialect::Postgres.new
  end

  def exec(query)
    request = OverpassParser.parse(query)
    sql = request.to_sql(@dialect)
    result = @@con.exec(sql)
    [sql, result.collect { |row| row['j'].gsub('+00:00', 'Z') }]
  end
end
