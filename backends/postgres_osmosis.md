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
cat /backends/postgres_osmosis_init.sql | psql $DATABASE_URL
```

```sql
```

## Run the server

Run the HTTP server
```
DATABASE_URL="postgresql://postgres@postgres:5432/postgres" bundle exec rackup
```
