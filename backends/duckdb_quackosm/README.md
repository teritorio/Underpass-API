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
quackosm /data/landes-latest.osm.pbf
mv files/landes-latest_nofilter_noclip_compact.parquet /data/extract_nofilter_noclip_compact.parquet
```

## Run the server

Run the HTTP server
```
docker compose up
```
