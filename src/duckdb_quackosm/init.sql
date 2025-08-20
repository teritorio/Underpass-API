INSTALL 'spatial';
LOAD 'spatial';

CREATE OR REPLACE TEMP VIEW node_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id < 'o';

CREATE OR REPLACE TEMP VIEW way_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'w';

CREATE OR REPLACE TEMP VIEW relation_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'o' AND feature_id < 's';

CREATE OR REPLACE TEMP VIEW nwr_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}';

CREATE OR REPLACE TEMP VIEW area_by_geom AS
SELECT split_part(feature_id, '/', 2)::bigint + CASE feature_id[1] WHEN 'r' THEN 3600000000 ELSE 0 END AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, CASE feature_id[1] WHEN 'w' THEN 'w' ELSE 'a' END AS osm_type FROM '#{parquet}' wHERE feature_id > 'm' AND list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geometry));

DROP TABLE IF EXISTS by_id_table;
CREATE TEMP TABLE by_id_table AS
SELECT
    *
FROM (
    SELECT 'n' AS osm_type, id, NULL::bigint[] AS nodes, tags, geom FROM node_by_geom
    UNION ALL
    SELECT 'w' AS osm_type, id, nodes, tags, geom FROM way_by_geom
    UNION ALL
    SELECT 'r' AS osm_type, id, NULL::bigint[] AS nodes, tags, geom FROM relation_by_geom
) AS t
ORDER BY
    osm_type,
    id
;

COPY by_id_table TO '#{parquet}_by_id' (FORMAT PARQUET);
