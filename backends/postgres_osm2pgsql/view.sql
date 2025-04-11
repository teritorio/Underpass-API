/************** WARNING *****************/
/*
This view is specific for a new database created with flex output geometries-alone.lua
*/


/************** ABOUT TABLES *****************/
/*
The flex output lua script creates:
- the 3 normal "middle" tables planet_osm_nodes, _ ways and _rels which include (all ans synchronised) OSM elements with (all) their tags and metadata. (tags need to be indexed after DB creation). And also _users table
- 3 additionnal "output" tables to store the geometries using SRID 4326 (to be compatible with overpass). 1 table per element type : nodes_geom, ways_geom and rels_geom
- the views join middle table (tags) with the corresponding output table (geometry) and also with users table (username)
*/

/************** NODES *****************/
CREATE OR REPLACE TEMP VIEW node AS
SELECT
  n.id AS id,
  n.version AS version,
  n.created AS created,
  n.changeset_id AS changeset,
  n.user_id AS uid,
  u.name AS user,
  /* if you did not use -x to get metadata, replace above lines by
  NULL::integer AS version,
  NULL::timestamp without time zone AS created,
  NULL::bigint AS changeset,
  NULL::integer AS uid,
  NULL::text AS user,
  */
  n.tags AS tags,
  NULL::bigint[] AS nodes,
  NULL::jsonb AS members,
  g.geom AS geom,
  NULL::real AS area,
  'n' AS osm_type
FROM planet_osm_nodes as n
LEFT JOIN planet_osm_users AS u ON n.user_id = u.id /* also remove this line */
LEFT JOIN nodes_geom AS g ON n.id = g.id
;

/************** WAYS *****************/
CREATE OR REPLACE TEMP VIEW way AS
SELECT
  w.id AS id,
  w.version AS version,
  w.created AS created,
  w.changeset_id AS changeset,
  w.user_id AS uid,
  u.name AS user,
  /* if you did not use -x to get metadata, replace above lines by
  NULL::integer AS version,
  NULL::timestamp without time zone AS created,
  NULL::bigint AS changeset,
  NULL::integer AS uid,
  NULL::text AS user,
  */
  w.tags as tags,
  w.nodes AS nodes,
  NULL::jsonb AS members,
  g.geom AS geom,
  g.area AS area,
  'w' AS osm_type
FROM planet_osm_ways AS w
LEFT JOIN planet_osm_users AS u ON w.user_id = u.id /* also remove this line */
LEFT JOIN ways_geom AS g ON w.id = g.id
;

/************** RELATIONS *****************/
CREATE OR REPLACE TEMP VIEW relation AS
SELECT
  r.id AS id,
  r.version AS version,
  r.created AS created,
  r.changeset_id AS changeset,
  r.user_id AS uid,
  u.name AS user,
  /* if you did not use -x to get metadata, replace above lines by
  NULL::integer AS version,
  NULL::timestamp without time zone AS created,
  NULL::bigint AS changeset,
  NULL::integer AS uid,
  NULL::text AS user,
  */
  r.tags as tags,
  NULL::bigint[] AS nodes,
  r.members AS members,
  g.geom AS geom,
  g.area AS area,
  'r' AS osm_type
FROM planet_osm_rels AS r
LEFT JOIN planet_osm_users AS u ON r.user_id = u.id /* also remove this line */
LEFT JOIN rels_geom AS g ON r.id = g.id
;

/************** NWR *****************/
CREATE OR REPLACE TEMP VIEW nwr AS
SELECT * FROM node
UNION ALL
SELECT * FROM way
UNION ALL
SELECT * FROM relation
;

/************** AREAS *****************/
CREATE OR REPLACE TEMP VIEW area AS
SELECT
  CASE
    WHEN osm_type='r' THEN 3600000000+id /* transform id of relations to be consistent with overpass */
    ELSE id
  END AS id,
  version,
  created,
  changeset,
  uid,
  user,
  tags,
  nodes,
  members,
  geom,
  area,
  REPLACE(osm_type, 'w', 'a') AS osm_type
FROM nwr
WHERE area IS NOT NULL
;