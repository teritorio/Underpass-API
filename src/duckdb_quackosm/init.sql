INSTALL 'spatial';
LOAD 'spatial';

COPY (
SELECT
    split_part(feature_id, '/', 2)::bigint AS id,
    tags,
    geometry AS geom,
    STRUCT_PACK(
        xmin := ST_XMin(geometry),
        ymin := ST_YMin(geometry),
        xmax := ST_XMax(geometry),
        ymax := ST_YMax(geometry)
    ) AS geom_bbox
FROM
    '#{parquet}'
WHERE
    feature_id[1] = 'n'
ORDER BY
    ST_Hilbert(
        geometry,
        ST_Extent(ST_MakeEnvelope(-180, -90, 180, 90))
    )
) TO '#{parquet}_nodes_by_geom' (FORMAT PARQUET);

COPY (
SELECT
    split_part(feature_id, '/', 2)::bigint AS id,
    tags,
    geometry AS geom,
    STRUCT_PACK(
        xmin := ST_XMin(geometry),
        ymin := ST_YMin(geometry),
        xmax := ST_XMax(geometry),
        ymax := ST_YMax(geometry)
    ) AS geom_bbox
FROM
    '#{parquet}'
WHERE
    feature_id[1] = 'w'
ORDER BY
    ST_Hilbert(
        geometry,
        ST_Extent(ST_MakeEnvelope(-180, -90, 180, 90))
    )
) TO '#{parquet}_ways_by_geom' (FORMAT PARQUET);

COPY (
SELECT
    split_part(feature_id, '/', 2)::bigint AS id,
    tags,
    geometry AS geom,
    STRUCT_PACK(
        xmin := ST_XMin(geometry),
        ymin := ST_YMin(geometry),
        xmax := ST_XMax(geometry),
        ymax := ST_YMax(geometry)
    ) AS geom_bbox
FROM
    '#{parquet}'
WHERE
    feature_id[1] = 'r'
ORDER BY
    ST_Hilbert(
        geometry,
        ST_Extent(ST_MakeEnvelope(-180, -90, 180, 90))
    )
) TO '#{parquet}_relations_by_geom' (FORMAT PARQUET);

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

COPY (SELECT id, tags, geom FROM node_by_geom ORDER BY id) TO '#{parquet}_nodes_by_id' (FORMAT PARQUET);
COPY (SELECT id, tags, geom FROM way_by_geom) TO '#{parquet}_ways_by_id' (FORMAT PARQUET);
COPY (SELECT id, tags, geom FROM relation_by_geom) TO '#{parquet}_relations_by_id' (FORMAT PARQUET);
