CREATE OR REPLACE TEMP VIEW node_by_geom AS
SELECT id, version, tstamp AS created, changeset_id AS changeset, user_id AS uid, NULL::text AS user, tags, NULL::bigint[] AS nodes, NULL::jsonb AS members, geom, 'n' AS osm_type FROM nodes;
CREATE OR REPLACE TEMP VIEW node_by_id AS SELECT * FROM node_by_geom;

CREATE OR REPLACE TEMP VIEW way_by_geom AS
SELECT id, version, tstamp AS created, changeset_id AS changeset, user_id AS uid, NULL::text AS user, tags, nodes, NULL::jsonb AS members, linestring AS geom, 'w' AS osm_type FROM ways;
CREATE OR REPLACE TEMP VIEW way_by_id AS SELECT * FROM way_by_geom;

CREATE OR REPLACE TEMP VIEW relation_by_geom AS
SELECT id, version, tstamp AS created, changeset_id AS changeset, user_id AS uid, NULL::text AS user, tags,  NULL::bigint[] AS nodes, NULL::jsonb AS members, NULL::geometry AS geom, 'r' AS osm_type FROM relations;
CREATE OR REPLACE TEMP VIEW relation_by_id AS SELECT * FROM relation_by_geom;

CREATE OR REPLACE TEMP VIEW nwr_by_geom AS
SELECT * FROM node_by_geom
UNION ALL
SELECT * FROM way_by_geom
UNION ALL
SELECT * FROM relation_by_geom
;
CREATE OR REPLACE TEMP VIEW nwr_by_id AS SELECT * FROM nwr_by_geom;

CREATE OR REPLACE TEMP VIEW area_by_geom AS
SELECT id, NULL::integer AS version, NULL::timestamp without time zone AS created, NULL::bigint AS changeset, NULL::integer AS uid, NULL::text AS user, tags, NULL::bigint[] AS nodes, NULL::jsonb AS members, poly AS geom, 'a' AS osm_type FROM multipolygons WHERE id > 3600000000
UNION ALL
SELECT id, version, tstamp::timestamp with time zone AS created, changeset_id AS changeset, user_id AS uid, NULL::text AS user, tags, nodes AS nodes, NULL::jsonb AS members, ST_MakePolygon(linestring)::geometry(Geometry,4326) AS geom, 'w' AS osm_type FROM ways WHERE id < 3600000000 AND ST_IsClosed(linestring) AND ST_Dimension(ST_MakePolygon(linestring)) = 2
;
CREATE OR REPLACE TEMP VIEW area_by_id AS SELECT * FROM area_by_geom;
