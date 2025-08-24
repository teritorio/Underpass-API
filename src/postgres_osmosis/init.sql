CREATE INDEX nodes_idx_tags ON nodes USING gist(tags) WHERE tags != ''::hstore;
CREATE INDEX ways_idx_tags ON ways USING gist(tags) WHERE tags != ''::hstore;
CREATE INDEX relations_idx_tags ON relations USING gist(tags) WHERE tags != ''::hstore;

DO $$
DECLARE
    mp RECORD;
BEGIN
    DROP TABLE IF EXISTS multipolygons CASCADE;
    CREATE UNLOGGED TABLE multipolygons (
        id bigint,
        tags hstore,
        poly geometry(Geometry, 4326) NOT NULL,
        is_valid boolean NOT NULL
    );

    FOR mp in (
        SELECT
            relations.id,
            relations.tags,
            ST_LineMerge(ST_Collect(ways.linestring)) AS linestrings
        FROM
            relations
            JOIN relation_members ON
                relation_members.relation_id = relations.id AND
                relation_members.member_type = 'W' AND
                relation_members.member_role IN ('outer', 'inner', '')
            LEFT JOIN ways ON
                ways.id = relation_members.member_id
        WHERE
            relations.tags->'type' IN ('multipolygon', 'boundary')
        GROUP BY
            relations.id
        HAVING
            -- Ensure all ways are downloaded; may be false at extract borders
            -- If false, calculations like ST_Area would give invalid results
            bool_and(ways.id IS NOT NULL) AND
            -- Avoid dealing with very large multi-polygons
            ST_NPoints(ST_Collect(ways.linestring)) < 100000
    ) LOOP
        BEGIN
            IF ST_BuildArea(mp.linestrings) IS NOT NULL AND NOT ST_IsEmpty(ST_BuildArea(mp.linestrings))
            -- Ensure no linestrings are dropped by ST_BuildArea, which would result in e.g. missing inners (see #2169)
            AND ST_CoveredBy(ST_Points(mp.linestrings), ST_Points(ST_BuildArea(mp.linestrings))) THEN
                WITH
                unary AS (
                    SELECT
                        id + 3600000000 AS id, tags,
                        (ST_Dump(poly)).geom AS poly
                    FROM (VALUES (
                        mp.id,
                        mp.tags,
                        ST_BuildArea(mp.linestrings)
                    )) AS t(id, tags, poly)
                ),
                simplified AS (
                    SELECT
                        id, tags,
                        ST_BuildArea(ST_Collect(
                            ST_ExteriorRing(poly),
                            (SELECT ST_Union(ST_MakePolygon(ST_InteriorRingN(poly, n))) FROM generate_series(1, ST_NumInteriorRings(poly)) AS t(n)) -- ST_MakePolygon is needed to union touching inner rings #2169
                        )) AS poly
                    FROM
                        unary
                ),
                multi AS (
                    SELECT
                        id, tags,
                        ST_CollectionHomogenize(ST_Collect(poly)) AS poly
                    FROM
                        simplified
                    GROUP BY
                        id, tags
                )
                INSERT INTO
                    multipolygons
                SELECT
                    *,
                    ST_IsValid(poly) AS is_valid -- see #2058 sometimes poly is considered valid but poly_proj not
                FROM
                    multi;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'multipolygon fails: %', mp.id;
        END;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';
