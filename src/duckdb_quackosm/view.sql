INSTALL 'spatial';
LOAD 'spatial';

CREATE OR REPLACE TEMP VIEW node_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id < 'o';

CREATE OR REPLACE TEMP VIEW node_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, osm_type FROM read_parquet('#{parquet}_by_id') WHERE osm_type = 'n';

CREATE OR REPLACE TEMP VIEW way_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'w';

CREATE OR REPLACE TEMP VIEW way_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, nodes, NULL::json AS members, geom, osm_type FROM read_parquet('#{parquet}_by_id') WHERE osm_type = 'w';

CREATE OR REPLACE TEMP VIEW relation_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'o' AND feature_id < 's';

CREATE OR REPLACE TEMP VIEW relation_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, osm_type FROM read_parquet('#{parquet}_by_id') WHERE osm_type = 'r';

CREATE OR REPLACE TEMP VIEW nwr_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}';

CREATE OR REPLACE TEMP VIEW nwr_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, osm_type FROM read_parquet('#{parquet}_by_id');

CREATE OR REPLACE TEMP VIEW area_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint + CASE feature_id[1] WHEN 'r' THEN 3600000000 ELSE 0 END AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, CASE feature_id[1] WHEN 'w' THEN 'w' ELSE 'a' END AS osm_type FROM '#{parquet}' wHERE feature_id > 'm' AND list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geometry));

CREATE OR REPLACE TEMP VIEW area_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'w' AS osm_type FROM read_parquet('#{parquet}_by_id')
wHERE
    osm_type = 'w' AND
    list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geom))
UNION ALL
SELECT id + 3600000000 AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'a' AS osm_type FROM read_parquet('#{parquet}_by_id')
wHERE
    osm_type = 'r' AND
    list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geom))
;
