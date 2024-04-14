# frozen_string_literal: true

require 'bundler/setup'
require 'hanami/api'
require 'duckdb'
require 'overpass_parser'
require 'overpass_parser/sql_dialect/duckdb'
require 'json'

class App < Hanami::API
  def initialize
    super
    parquet = ENV['DB']

    db = DuckDB::Database.open # database in memory
    @@con = db.connect

    @@con.query("
    INSTALL 'spatial';
    LOAD 'spatial';

    CREATE OR REPLACE TEMP VIEW node AS
    SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, tags, NULL::bigint[] AS nodes, NULL::json AS members, ST_GeomFromWKB(geometry) AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id < 'o';

    CREATE OR REPLACE TEMP VIEW way AS
    SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, tags, NULL::bigint[] AS nodes, NULL::json AS members, ST_GeomFromWKB(geometry) AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'w';

    CREATE OR REPLACE TEMP VIEW relation AS
    SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, tags, NULL::bigint[] AS nodes, NULL::json AS members, ST_GeomFromWKB(geometry) AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'o' AND feature_id < 's';

    CREATE OR REPLACE TEMP VIEW nwr AS
    SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, tags, NULL::bigint[] AS nodes, NULL::json AS members, ST_GeomFromWKB(geometry) AS geom, feature_id[1] AS osm_type FROM '#{parquet}';

    CREATE OR REPLACE TEMP VIEW area AS
    SELECT split_part(feature_id, '/', 2)::bigint + CASE feature_id[1] WHEN 'r' THEN 3600000000 ELSE 0 END AS id, NULL::int AS version, NULL::timestamp AS created, tags, NULL::bigint[] AS nodes, NULL::json AS members, ST_GeomFromWKB(geometry) AS geom, CASE feature_id[1] WHEN 'w' THEN 'w' ELSE 'a' END AS osm_type FROM '#{parquet}' wHERE feature_id > 'm' AND list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(ST_GeomFromWKB(geometry)));
    ")
  end

  def self.overpass(query); end

  get '/interpreter' do
    query = params[:data]
    begin
      request = OverpassParser.parse(query)
      dialect = OverpassParser::SqlDialect::Duckdb.new
      sql = request.to_sql(dialect)
        result = @@con.query(sql)
      # "timestamp_osm_base": "2024-04-08T20:16:26Z",
      # "timestamp_areas_base": "2024-04-08T16:33:59Z",
      json = "{
\"version\": 0.6,
\"generator\": \"underpass\",
\"osm3s\": {
  \"backend\": \"#{dialect.class.name}\",
  \"query\": \"#{sql.gsub("\n", '\\n').gsub('\\', '\\\\').gsub('"', '\\"')}\",
  \"copyright\": \"The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.\"
},
\"elements\": [" + result.collect(&:first).join(",\n") + ']}'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Content-Type'] = 'application/json'
      body(json)
    rescue OverpassParser::ParsingError => e
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Content-Type'] = 'text/html'
      body("<html>
<body>
<p><strong style=\"color:#FF0000\">Error</strong>: #{e}</p>
</body>
</html>")
    end
  end

  post '/interpreter' do
    query = params[:data]
    begin
      request = OverpassParser.parse(query)
      dialect = OverpassParser::SqlDialect::Duckdb.new
      sql = request.to_sql(dialect)
      result = @@con.query(sql)
      # "timestamp_osm_base": "2024-04-08T20:16:26Z",
      # "timestamp_areas_base": "2024-04-08T16:33:59Z",
      json = "{
\"version\": 0.6,
\"generator\": \"underpass\",
\"osm3s\": {
  \"backend\": \"#{dialect.class.name}\",
  \"query\": \"#{sql.gsub("\n", '\\n').gsub('\\', '\\\\').gsub('"', '\\"')}\",
  \"copyright\": \"The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.\"
},
\"elements\": [" + result.collect(&:first).join(",\n") + ']}'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Content-Type'] = 'application/json'
      body(json)
    rescue OverpassParser::ParsingError => e
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Content-Type'] = 'text/html'
      body("<html>
<body>
<p><strong style=\"color:#FF0000\">Error</strong>: #{e}</p>
</body>
</html>")
    end
  end
end

run App.new
