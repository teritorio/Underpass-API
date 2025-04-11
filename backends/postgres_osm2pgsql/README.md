# Postgres/PostGIS, Osm2pgsql schema

Prepare Docker
```sh
docker compose --profile '*' build
```

## Prepare the data

### 1. View for a new, dedicated, updatable and complete DB

This view is configured to be a true alternative to overpass, in the sense that there is no filtering on the elements included in the DB. They are all included in the DB with all their tags, whereas osm2pgsql is usually configured not to include tags or elements that are useless for generating tiles.

Warning : this wiew will not work on an existing osm2pgsql database (see below). It is specific for a database created with the lua script above and the `-s (--slim)` option.

Create you database with osm2pgsql, using the script `geometries-alone.lua` available in this folder.

Example command:

```
osm2pgsql -U user -d database -c -s --flat-nodes FILE --middle-with-nodes -x -O flex -S geometries-alone.lua extract.osm.pbf
```

Explanation of the command:
- `-c -s -x`: create an updatable table including metadata
- `--flat-nodes FILE --middle-with-nodes`: use the file `FILE` to store nodes (to reduce the size of the DB), but nodes with tags are also stored in the database (so that filtering by tag will be possible on nodes)
- `-O flex -S geometries-alone.lua`: use flex output mode with specific `.lua` file

One finished, add index for tags:
```
CREATE INDEX nodes_tags_idx ON planet_osm_nodes USING GIN (tags);
CREATE INDEX ways_tags_idx ON planet_osm_ways USING GIN (tags);
CREATE INDEX rels_tags_idx ON planet_osm_rels USING GIN (tags);
```

Use `osm2pgsql-replication` to update the DB.

Sizing
- 57GB for France (29GB for middle tables (metadata+tags) + 2GB for tag index + 26GB for output tables (geometries))

If your database was created "outside" docker, you will have to modify `docker-compose.yaml` to:
  - delete services `osm2pgsql` and `postgress`
  - in service api : delete reference `depends on: -postgres` and set your `DATABASE_URL: postgres://user:pw@host:5432/database`

Explanation of the `.lua` script and principle of the DB structure:
- `-s` option creates `middle` tables which include all raw OSM elements (`planet_osm_nodes`, `planet_osm_ways`, `planet_osm_rels`) with all their tags. This view uses these 3 tables to get tags (no need to duplicate them in `output` tables), but we need to manually index them at the beginning.
- `-x` option add columns for metadata in these tables, and table `planet_osm_users` for usernames.
- so only the geometries are missing. The `.lua` script of the `flex output` creates 3 additionnal `output` tables: `nodes_geom`, `ways_geom` and `rels_geom` with the id and the geometry.
  - I had to use tables by element type instead of geometry type (as usual for osm2pgsql) since the negative id used for relations in area type table is problematic for the join with the `planet_osm_rels` table which uses normal positive id (join is slow since indexing is not working).
- For a list of expected areas (as usual in osm2pgsql), the lua script creates polygon-like geometries (instead of line-like) and adds the area size in a 3rd column (it will be usefull to get areas).

### 2. View for an existing DB created for cartocss

not written yet

### 3. View for a simple static DB (without synchronisation)

not written yet

## Run the server

Run the HTTP server
```
docker compose up
```
