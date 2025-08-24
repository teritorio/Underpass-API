INSTALL 'spatial';
LOAD 'spatial';

CREATE OR REPLACE TEMP VIEW sorted AS
WITH a AS (
SELECT
    feature_id[1] AS osm_type,
    split_part(feature_id, '/', 2)::bigint AS id,
    tags,
    geometry AS geom,
    STRUCT_PACK(
        xmin := ST_XMin(geometry),
        ymin := ST_YMin(geometry),
        xmax := ST_XMax(geometry),
        ymax := ST_YMax(geometry)
    ) AS bbox,
FROM
    '#{parquet}'
ORDER BY
    ST_Hilbert(
        geometry,
        ST_Extent(ST_MakeEnvelope(-180, -90, 180, 90))
    )
)
SELECT
    *,
    row_number() OVER () AS rid
FROM
    a
;


-- nodes

DROP TABLE IF EXISTS nodes_by_geom;
CREATE TEMP TABLE nodes_by_geom AS
SELECT id, rid, tags, geom, bbox FROM sorted WHERE osm_type = 'n';
COPY nodes_by_geom
TO '#{parquet}_nodes_by_geom' (FORMAT PARQUET);

COPY (
    SELECT id, rid FROM nodes_by_geom ORDER BY id
)
TO '#{parquet}_nodes_by_id' (FORMAT PARQUET);
DROP TABLE IF EXISTS nodes_by_geom;


-- ways

DROP TABLE IF EXISTS ways_small_by_geom;
CREATE TEMP TABLE ways_small_by_geom AS
SELECT id, id AS aid, rid, tags, geom, bbox FROM sorted
WHERE
    osm_type = 'w' AND
    ST_Length_Spheroid(
        ST_MakeLine(ST_Point(ST_XMin(geom), ST_YMin(geom)), ST_Point(ST_XMax(geom), ST_YMax(geom)))
    ) < 1000
;
COPY ways_small_by_geom
TO '#{parquet}_ways_small_by_geom' (FORMAT PARQUET);

COPY (
    SELECT id, rid FROM ways_small_by_geom ORDER BY id
)
TO '#{parquet}_ways_small_by_id' (FORMAT PARQUET);
DROP TABLE IF EXISTS ways_small_by_geom;

DROP TABLE IF EXISTS ways_large_by_geom;
CREATE TEMP TABLE ways_large_by_geom AS
SELECT id, id AS aid, rid, tags, geom, bbox FROM sorted
WHERE
    osm_type = 'w' AND
    ST_Length_Spheroid(
        ST_MakeLine(ST_Point(ST_XMin(geom), ST_YMin(geom)), ST_Point(ST_XMax(geom), ST_YMax(geom)))
    ) >= 1000
;
COPY ways_large_by_geom
TO '#{parquet}_ways_large_by_geom' (FORMAT PARQUET);

COPY (
    SELECT id, rid FROM ways_large_by_geom ORDER BY id
)
TO '#{parquet}_ways_large_by_id' (FORMAT PARQUET);
DROP TABLE IF EXISTS ways_large_by_geom;


-- relations

DROP TABLE IF EXISTS relations_small_by_geom;
CREATE TEMP TABLE relations_small_by_geom AS
SELECT id, id + 3600000000 AS aid, rid, tags, geom, bbox FROM sorted
WHERE
    osm_type = 'r   ' AND
    ST_Length_Spheroid(
        ST_MakeLine(ST_Point(ST_XMin(geom), ST_YMin(geom)), ST_Point(ST_XMax(geom), ST_YMax(geom)))
    ) < 1000
;
COPY relations_small_by_geom
TO '#{parquet}_relations_small_by_geom' (FORMAT PARQUET);

COPY (
    SELECT id, rid FROM relations_small_by_geom ORDER BY id
)
TO '#{parquet}_relations_small_by_id' (FORMAT PARQUET);
DROP TABLE IF EXISTS relations_small_by_geom;

DROP TABLE IF EXISTS relations_large_by_geom;
CREATE TEMP TABLE relations_large_by_geom AS
SELECT id, id + 3600000000 AS aid, rid, tags, geom, bbox FROM sorted
WHERE
    osm_type = 'r' AND
    ST_Length_Spheroid(
        ST_MakeLine(ST_Point(ST_XMin(geom), ST_YMin(geom)), ST_Point(ST_XMax(geom), ST_YMax(geom)))
    ) >= 1000
;
COPY relations_large_by_geom
TO '#{parquet}_relations_large_by_geom' (FORMAT PARQUET);

COPY (
    SELECT id, rid FROM relations_large_by_geom ORDER BY id
)
TO '#{parquet}_relations_large_by_id' (FORMAT PARQUET);
DROP TABLE IF EXISTS relations_large_by_geom;
