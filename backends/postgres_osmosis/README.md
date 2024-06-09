# Postgres/PostGIS, Osmosis schema

Prepare Docker
```sh
docker compose --profile '*' build
```

## Prepare the data

```sh
docker compose run --rm osmosis
```

```sh
psql $DATABASE_URL -v ON_ERROR_STOP=1 -c "CREATE EXTENSION hstore;"
psql $DATABASE_URL -v ON_ERROR_STOP=1 -c "CREATE EXTENSION postgis;"
cat /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6.sql | psql $DATABASE_URL -v ON_ERROR_STOP=1
cat /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6_linestring.sql | psql $DATABASE_URL -v ON_ERROR_STOP=1
osmosis \
  --read-pbf /data/landes-latest.osm.pbf \
  --write-pgsql host=postgres database=postgres user=postgres password=postgres
cat /backends/postgres_osmosis_init.sql | psql $DATABASE_URL -v ON_ERROR_STOP=1
```

## Run the server

Run the HTTP server
```
docker compose up
```
