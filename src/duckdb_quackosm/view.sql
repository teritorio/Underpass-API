INSTALL 'spatial';
LOAD 'spatial';

CREATE OR REPLACE TEMP VIEW node_by_geom AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'n' AS osm_type
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
SELECT id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_small_by_geom')
UNION ALL
SELECT id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_large_by_geom')
;

CREATE OR REPLACE TEMP VIEW relation_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_by_id');

CREATE OR REPLACE TEMP VIEW nwr_by_geom AS
SELECT id, version, created, changeset, uid, tags, nodes, members, geom, bbox, osm_type FROM node_by_geom
UNION ALL
SELECT id, version, created, changeset, uid, tags, nodes, members, geom, bbox, osm_type FROM way_by_geom
UNION ALL
SELECT id, version, created, changeset, uid, tags, nodes, members, geom, bbox, osm_type FROM relation_by_geom
;

CREATE OR REPLACE TEMP VIEW nwr_by_id AS
SELECT * FROM node_by_id
UNION ALL
SELECT * FROM way_by_id
UNION ALL
SELECT * FROM relation_by_id
;

CREATE OR REPLACE TEMP VIEW area_by_geom AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM way_by_geom
UNION ALL
SELECT aid AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'a' AS osm_type FROM relation_by_geom
;

CREATE OR REPLACE TEMP VIEW area_by_id AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'w' AS osm_type FROM read_parquet('#{parquet}_ways_by_id')
UNION ALL
SELECT aid AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, 'a' AS osm_type FROM read_parquet('#{parquet}_relations_by_id')
;
