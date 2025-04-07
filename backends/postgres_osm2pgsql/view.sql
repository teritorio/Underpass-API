/************** ABOUT TABLES *****************/
/*
- without the --slim option, only "output" tables are created (PREFIX_point PREFIX_line and PREFIX_polygon in the case of the deprecated pgsql output) and they contain elements filtered based on their tags (using list and parameters in .style file). These tables also contain the geometry.
- with --slim, 3 other "middle" tables containing ALL the raw OSM elements are created : _nodes, _ways, _rels
*/

/************** ABOUT GEOMETRY *****************/
/*
Underpass as Overpass uses SRID 4326 whereas osm2pgsql uses by default SRID 3857
To make Underpass works on your osm2pgsl database, you have to CREATE it with option --proj=4326 (for the case of deprecated pgsql output) or define that the tables will use SRID 4326 (for the case of the modern flex output)
If you want to deploy Underpass on an existing osm2pgsl database, you will have to modify both this backend and overpass_parser-rb, so that the parser transforms bbox and areas and others in SRID 3857 to allow comparison with the geom in your DB
*/

/************** ABOUT TAGS COLUMNS *****************/
/*
- tags in "middle" tables _nodes, _ways, _rels are identical to the ones in OSM (they are "raw data" tables)
- but tags in "output" tables are always (slightly) different depending on the hstore options:
  # With --hstore any tags without a column will be added to the hstore column.
  # With --hstore-all all tags are added to the hstore column unless they appear in the style file with a delete flag
*/

/************** ABOUT METADATA *****************/
/* adding metadata to the DB requires -x option */
/* without it, all the CAST(tags->...) will return NULL */


/******** UNION LINES AND POLYGONS **********/
CREATE OR REPLACE TEMP VIEW lines_and_polygons AS
SELECT id, geom, NULL::real as area FROM lines
UNION ALL
SELECT * FROM polygons
;


/************** NODES *****************/
/* requires database creation with either :
    - option --slim without --flat-nodes
    - options --slim --flat-nodes FILE --middle-with-nodes */
CREATE OR REPLACE TEMP VIEW node AS
SELECT
  n.id AS id,
  n.version AS version,
  n.created AS created,
  n.changeset_id AS changeset,
  n.user_id AS uid,
  u.name AS user,
  /* if you did not use --extra-attributes, replace above lines by
  NULL::integer AS version,
  NULL::timestamp without time zone AS created,
  NULL::bigint AS changeset,
  NULL::integer AS uid,
  NULL::text AS user,
  */
  n.tags AS tags,
  NULL::bigint[] AS nodes,
  NULL::jsonb AS members,
  p.geom AS geom,
  NULL::real AS area,
  'n' AS osm_type
FROM planet_osm_nodes as n
LEFT JOIN planet_osm_users AS u ON n.user_id = u.id /* also remove this line */
LEFT JOIN points AS p ON n.id = p.id
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
  /* if you did not use --extra-attributes, replace above lines by
  NULL::integer AS version,
  NULL::timestamp without time zone AS created,
  NULL::bigint AS changeset,
  NULL::integer AS uid,
  NULL::text AS user,
  */
  w.tags as tags,
  w.nodes AS nodes,
  NULL::jsonb AS members,
  lp.geom AS geom,
  lp.area AS area,
  'w' AS osm_type
FROM planet_osm_ways AS w
LEFT JOIN planet_osm_users AS u ON w.user_id = u.id /* also remove this line */
LEFT JOIN lines_and_polygons AS lp ON w.id = lp.id
;


/************** RELATIONS *****************/
/* complete version (based on table _rels) if you used --slim */
CREATE OR REPLACE TEMP VIEW relation AS
SELECT
  r.id AS id,
  r.version AS version,
  r.created AS created,
  r.changeset_id AS changeset,
  r.user_id AS uid,
  u.name AS user,
  /* if you did not use --extra-attributes, replace above lines by
  NULL::integer AS version,
  NULL::timestamp without time zone AS created,
  NULL::bigint AS changeset,
  NULL::integer AS uid,
  NULL::text AS user,
  */
  r.tags as tags,
  NULL::bigint[] AS nodes,
  r.members AS members,
  lp.geom AS geom,
  lp.area AS area,
  'r' AS osm_type
FROM planet_osm_rels AS r
LEFT JOIN planet_osm_users AS u ON r.user_id = u.id /* also remove this line */
LEFT JOIN lines_and_polygons AS lp ON r.id = -lp.id
;


/************** NWR *****************/
CREATE OR REPLACE TEMP VIEW nwr AS
SELECT * FROM node
UNION ALL
SELECT * FROM way
UNION ALL
SELECT * FROM relation
;

/************** AREA *****************/
CREATE OR REPLACE TEMP VIEW area AS
SELECT
  CASE
    WHEN osm_type='r' THEN 3600000000+id /* transform if of relations to be consistent with overpass */
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
  /*CASE
    WHEN osm_type='r' THEN 'a' /* transform r in a for underpass ? */
    ELSE osm_type
  END AS osm_type,*/
FROM nwr
WHERE area IS NOT NULL
;