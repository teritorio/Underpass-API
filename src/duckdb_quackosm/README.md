# DuckDB/Spatial, Quackosm schema

Prepare Docker
```sh
docker compose --profile '*' build
```

## Prepare the data

```sh
docker compose run --rm quackosm
```

```sh
quackosm --no-sort /data/landes-latest.osm.pbf
mv files/*.parquet /data/
```

You can now remove the `*.osm.pbf` file.

Adjuste the DB filename in `docker-compose.yaml`.

```sh
docker compose run --rm api underpass-api init
```

You can now remove the QuackOSM `*_nofilter_noclip_compact.parquet` file.

## Run the server

Run the HTTP server
```
docker compose up
```
