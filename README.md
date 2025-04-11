# Underpass-API

An Overpass-API on SQL Database.

Underpass-API aim to be a [Overpass-API](https://github.com/drolbr/Overpass-API) compatible engine built upon [converter](https://github.com/teritorio/overpass_parser-rb) from Overpass Language to SQL.

## Prepare the data & Run the server

### With docker (recommended)

Follow the instruction of one of the backends:
* [DuckDB+Spatial / QuackOSM](backends/duckdb_quackosm/README.md), Quackosm schema
* [Postgres+PostGIS / Osmosis](backends/postgres_osmosis/README.md), Osmosis schema
* [Postgres+PostGIS / Osm2pgsql](backends/postgres_osm2pgsql/README.md), Osm2pgsql schema using a specific `flex output`

### Without Docker

It is possible to use Underpass-API without Docker with the following instructions :

* Install Ruby dependencies with `bundle install`.
* Start the server with
  * `BACKEND="DuckdbQuackosm" DB="data/database.parquet" bundle exec rackup`
  * `BACKEND="PostgresOsmosis" DB="postgresql://user:pw@host:5432/database" bundle exec rackup`

Fo details about setup, looks at specific backend directory, and in Dockerfile for system dependencies.

## Query

The API as available at http://localhost:9292/interpreter

## Performance

Test with the [Gironde, France](http://download.openstreetmap.fr/extracts/europe/france/aquitaine/gironde-latest.osm.pbf) extract (94MB).
Test with generic index, running localy, 8 CPU, 8 GB RAM.

Test Query 1
```
[out:json][timeout:25];
(
  nwr[highway=bus_stop][name];
  nwr[public_transport=platform];
);
out center meta;
```

time curl 'http://localhost:9292/interpreter' -X POST -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data-raw 'data=%5Bout%3Ajson%5D%5Btimeout%3A25%5D%3B%0A(%0A++nwr%5Bhighway%3Dbus_stop%5D%5Bname%5D%3B%0A++nwr%5Bpublic_transport%3Dplatform%5D%3B%0A)%3B%0Aout+center+meta%3B'

| Backend                          | Setup  | Query 1 |
|----------------------------------|--------|---------|
| Postgres+PostGIS / Osmosis       | 10m11s |    5,7s |
| DuckDB+Spatial / QuackOSM (1)    |  2m00s |    2,4s |
| Overpass API (2)                 |  8m49s |    3,1s |
| Overpass API overpass-api.de (3) |      - |    5,9s |

(1) Without metadata.
(2) Required converion from PBF to XML included ().
(3) Query with polygon to limit the spatial extent.
