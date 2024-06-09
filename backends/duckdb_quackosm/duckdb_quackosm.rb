# frozen_string_literal: true

require 'duckdb'
require 'overpass_parser/sql_dialect/duckdb'

class DuckdbQuackosm
  def initialize
    parquet = ENV['DB']
    db = DuckDB::Database.open # database in memory
    @@con = db.connect
    @@con.query(File.read(File.dirname(__FILE__) + '/view.sql').gsub('#{parquet}', parquet))

    @dialect = OverpassParser::SqlDialect::Duckdb.new
  end

  def exec(query)
    request = OverpassParser.parse(query)
    sql = request.to_sql(@dialect)
    result = @@con.query(sql)
    [sql, result.collect(&:first)]
  end
end
