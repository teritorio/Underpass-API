INSTALL 'spatial';
LOAD 'spatial';

CREATE OR REPLACE TEMP VIEW node_by_geom AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom,
    STRUCT_PACK(
        xmin := ST_X(geom),
        ymin := ST_Y(geom),
        xmax := ST_X(geom),
        ymax := ST_Y(geom)
    ) AS bbox, 'n' AS osm_type
FROM read_parquet('#{parquet}_nodes_by_geom');

CREATE OR REPLACE TEMP VIEW node_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'n' AS osm_type FROM read_parquet('#{parquet}_nodes_by_id');

CREATE OR REPLACE TEMP VIEW way_by_geom AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM read_parquet('#{parquet}_ways_small_by_geom')
UNION ALL
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM read_parquet('#{parquet}_ways_large_by_geom')
;

CREATE OR REPLACE TEMP VIEW way_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'w' AS osm_type FROM read_parquet('#{parquet}_ways_by_id') WHERE osm_type = 'w';

CREATE OR REPLACE TEMP VIEW relation_by_geom AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_small_by_geom')
UNION ALL
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_small_by_geom')
;

CREATE OR REPLACE TEMP VIEW relation_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_by_id');

CREATE OR REPLACE TEMP VIEW nwr_by_geom AS
SELECT * FROM node_by_geom
UNION ALL
SELECT * FROM way_by_geom
UNION ALL
SELECT * FROM relation_by_geom
;

CREATE OR REPLACE TEMP VIEW nwr_by_id AS
SELECT * FROM node_by_id
UNION ALL
SELECT * FROM way_by_id
UNION ALL
SELECT * FROM relation_by_id
;

CREATE OR REPLACE TEMP VIEW area_by_geom AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM way_by_geom wHERE list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geom))
UNION ALL
SELECT id + 3600000000 AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'a' AS osm_type FROM relation_by_geom wHERE list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geom))
;

CREATE OR REPLACE TEMP VIEW area_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'w' AS osm_type FROM read_parquet('#{parquet}_ways_by_id')
wHERE
    list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geom))
UNION ALL
SELECT id + 3600000000 AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'a' AS osm_type FROM read_parquet('#{parquet}_relations_by_id')
wHERE
    list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geom))
;
