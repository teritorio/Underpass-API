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
mv files/landes-latest_nofilter_noclip_compact.parquet /data/landes-latest_nofilter_noclip_compact.parquet
```

```sh
cd ..
BACKEND="DuckdbQuackosm" DB="data/data/landes-latest_nofilter_noclip_compact.parquet" cargo run -- init data/landes-latest_nofilter_noclip_compact.parquet
```

## Run the server

Run the HTTP server
```
docker compose up
```
