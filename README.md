# Underpass-API

An Overpass-API on SQL Database.

Underpass-API aim to be a [Overpass-API](https://github.com/drolbr/Overpass-API) compatible engine built upon [converter](https://github.com/teritorio/overpass_parser-rb) from Overpass Language to SQL.

## Prepare the data & Run the server

Folow the instruction of one of the backends:
* [Postgres+PostGIS / Osmosis](backends/postgres_osmosis/README.md), Osmosis schema
* [DuckDB+Spatial / QuackOSM](backends/duckdb_quackosm/README.md), Quackosm schema

## Query

The API as available at http://localhost:9292/interpreter
