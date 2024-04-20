CREATE OR REPLACE TEMP VIEW node AS
SELECT id, version, tstamp::timestamp with time zone AS created, tags, NULL::bigint[] AS nodes, NULL::jsonb AS members, geom, 'n' AS osm_type FROM nodes;

CREATE OR REPLACE TEMP VIEW way AS
SELECT id, version, tstamp::timestamp with time zone AS created, tags, nodes, NULL::jsonb AS members, linestring AS geom, 'w' AS osm_type FROM ways;

CREATE OR REPLACE TEMP VIEW relation AS
SELECT
    id,
    version,
    tstamp::timestamp with time zone AS created,
    tags,
    NULL::bigint[] AS nodes,
    jsonb_agg(jsonb_build_object(
        'type', CASE relation_members.member_type WHEN 'N' THEN 'node' WHEN 'W' THEN 'way' WHEN 'R' THEN 'relation' END,
        'ref', relation_members.member_id,
        'role', relation_members.member_role
    )) AS members,
    NULL::geometry AS geom,
    'r' AS osm_type
FROM relations
    JOIN relation_members ON
        relation_members.relation_id = relations.id
GROUP BY
    relations.id,
    relations.version,
    relations.tstamp,
    relations.tags
;

CREATE OR REPLACE TEMP VIEW nwr AS
SELECT * FROM node
UNION ALL
SELECT * FROM way
UNION ALL
SELECT * FROM relation
;

CREATE OR REPLACE TEMP VIEW area AS
SELECT id, NULL::integer AS version, NULL::timestamp with time zone AS created, tags, NULL::bigint[] AS nodes, NULL::jsonb AS members, poly AS geom, 'a' AS osm_type FROM multipolygons WHERE id > 3600000000
UNION ALL
SELECT id, version, tstamp::timestamp with time zone AS created, tags, nodes AS nodes, NULL::jsonb AS members, ST_MakePolygon(linestring)::geometry(Geometry,4326) AS geom, 'w' AS osm_type FROM ways WHERE id < 3600000000 AND ST_IsClosed(linestring) AND ST_Dimension(ST_MakePolygon(linestring)) = 2
;
