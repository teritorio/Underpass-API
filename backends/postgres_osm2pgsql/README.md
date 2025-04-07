# Postgres/PostGIS, Osm2pgsql schema

Prepare Docker
```sh
docker compose --profile '*' build
```

## Prepare the data

Create you database with osm2pgsql, using the script `geometries-alone.lua` in this folder.

Example command :

```
osm2pgsql -U user -d database -c -s --flat-nodes DB-flat-nodes --middle-with-nodes -x -O flex -S geometries-alone.lua extract.osm.pbf
```

Warning : this backend will not work on a existing osm2pgsql database. it is specific for a database created with the lua script above and the `-s (--slim)` option.

If your database was created "outside" docker, you will have to modify `docker-compose.yaml` to:
  - delete services `osm2pgsql` and `postgress`
  - in service api : delete reference `depends on: -postgres` and set your `DATABASE_URL: postgres://user:pw@host:5432/database`

## Run the server

Run the HTTP server
```
docker compose up
```
