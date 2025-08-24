INSTALL 'spatial';
LOAD 'spatial';


-- nodes

CREATE OR REPLACE TEMP VIEW node_by_geom AS
SELECT id, NULL as aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'n' AS osm_type
FROM read_parquet('#{parquet}_nodes_by_geom');

CREATE OR REPLACE TEMP VIEW node_by_id AS
SELECT
    id, NULL as aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'n' AS osm_type
FROM
    read_parquet('#{parquet}_nodes_by_id') AS nodes_by_id
    JOIN read_parquet('#{parquet}_nodes_by_geom') AS nodes_by_geom USING (rid, id)
;


-- ways

CREATE OR REPLACE TEMP VIEW way_by_geom AS
SELECT id, id AS aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM read_parquet('#{parquet}_ways_small_by_geom')
UNION ALL
SELECT id, id AS aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM read_parquet('#{parquet}_ways_large_by_geom')
;

CREATE OR REPLACE TEMP VIEW way_by_id AS
SELECT
    id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS ways, NULL::json AS members, geom, bbox, 'n' AS osm_type
FROM
    read_parquet('#{parquet}_ways_small_by_id') AS ways_by_id
    JOIN read_parquet('#{parquet}_ways_small_by_geom') AS ways_by_geom USING (rid, id)
UNION ALL
SELECT
    id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS ways, NULL::json AS members, geom, bbox, 'n' AS osm_type
FROM
    read_parquet('#{parquet}_ways_large_by_id') AS ways_by_id
    JOIN read_parquet('#{parquet}_ways_large_by_geom') AS ways_by_geom USING (rid, id)
;


-- relations

CREATE OR REPLACE TEMP VIEW relation_by_geom AS
SELECT id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_small_by_geom')
UNION ALL
SELECT id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'r' AS osm_type FROM read_parquet('#{parquet}_relations_large_by_geom')
;

CREATE OR REPLACE TEMP VIEW relation_by_id AS
SELECT
    id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS relations, NULL::json AS members, geom, bbox, 'n' AS osm_type
FROM
    read_parquet('#{parquet}_relations_small_by_id') AS relations_by_id
    JOIN read_parquet('#{parquet}_relations_small_by_geom') AS relations_by_geom USING (rid, id)
UNION ALL
SELECT
    id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS relations, NULL::json AS members, geom, bbox, 'n' AS osm_type
FROM
    read_parquet('#{parquet}_relations_large_by_id') AS relations_by_id
    JOIN read_parquet('#{parquet}_relations_large_by_geom') AS relations_by_geom USING (rid, id)
;


-- nwr

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


-- area

CREATE OR REPLACE TEMP VIEW area_by_geom AS
SELECT id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM way_by_geom WHERE id <= 3600000000
UNION ALL
SELECT aid AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'a' AS osm_type FROM relation_by_geom WHERE aid > 3600000000
;

CREATE OR REPLACE TEMP VIEW area_by_id AS
SELECT id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'w' AS osm_type FROM way_by_id WHERE id <= 3600000000
UNION ALL
SELECT aid AS id, aid, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geom, bbox, 'a' AS osm_type FROM relation_by_id WHERE aid > 3600000000
;
