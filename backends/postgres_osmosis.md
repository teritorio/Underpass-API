# Postgres/PostGIS, Osmosis schema

## Prepare the data

```sh
docker-compose run --rm osmosis
```

```sh
cat /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6.sql | psql $DATABASE_URL
cat /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6_linestring.sql | psql $DATABASE_URL
osmosis \
  --read-pbf /data/landes-latest.osm.pbf \
  --write-pgsql host=postgres database=postgres user=postgres password=postgres
```

```sql
CREATE INDEX nodes_idx_tags ON nodes USING gist(tags) WHERE tags != ''::hstore;
CREATE INDEX ways_idx_tags ON ways USING gist(tags) WHERE tags != ''::hstore;
CREATE INDEX relations_idx_tags ON relations USING gist(tags) WHERE tags != ''::hstore;

CREATE INDEX ways_idx_geom ON nodes USING gist(geom);
CREATE INDEX ways_idx_linestring ON ways USING gist(linestring);
```

## Run the server

Run the HTTP server
```
DATABASE_URL="postgresql://postgres@postgres:5432/postgres" bundle exec rackup
```
