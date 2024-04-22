# frozen_string_literal: true

require 'pg'
require 'overpass_parser/sql_dialect/postgres'

class PostgresOsmosis
  def initialize
    @@con = PG.connect(ENV['DATABASE_URL'])
    @@con.query(File.read(__FILE__.gsub(/\.rb$/, '.sql')))
    @dialect = OverpassParser::SqlDialect::Postgres.new(postgres_escape_literal: ->(s) { @@con.escape_literal(s) })
  end

  def exec(query)
    request = OverpassParser.parse(query)
    sql = request.to_sql(
      @dialect,
      "
SELECT
  results.id,
  results.version,
  results.tstamp::timestamp with time zone AS created,
  results.changeset_id AS changeset,
  users.name AS user,
  results.user_id AS uid,
  results.tags,
  results.nodes,
  nullif(jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
    'type', CASE relation_members.member_type WHEN 'N' THEN 'node' WHEN 'W' THEN 'way' WHEN 'R' THEN 'relation' END,
    'ref', relation_members.member_id,
    'role', relation_members.member_role
  ))), '[{}]'::jsonb) AS members,
  results.geom,
  results.osm_type
FROM
  {{query}} AS results
  LEFT JOIN users ON
    users.id = results.user_id
  LEFT JOIN relation_members ON
    results.osm_type = 'r' AND
    relation_members.relation_id = results.id
GROUP BY
    results.id,
    results.version,
    results.tstamp,
    results.changeset_id,
    users.name,
    results.user_id,
    results.tags,
    results.nodes,
    results.geom,
    results.osm_type"
    )
    puts sql
    result = @@con.exec(sql)
    [sql, result.collect { |row| row['j'].gsub('+00:00', 'Z') }]
  end
end
