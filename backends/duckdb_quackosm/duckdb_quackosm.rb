# frozen_string_literal: true

require 'duckdb'

class DuckdbQuackosm
  def initialize
    parquet = ENV['DB']
    db = DuckDB::Database.open # database in memory
    @@con = db.connect
    @@con.query(File.read(File.dirname(__FILE__) + '/view.sql').gsub('#{parquet}', parquet))

    @dialect = 'duckdb'
  end

  def exec(query)
    request = OverpassParserRuby.parse(query)
    sql = request.to_sql(@dialect, 4326)
    result = @@con.query(sql)
    [sql, result.collect(&:first)]
  end
end
