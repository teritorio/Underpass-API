# Underpass-API

An Overpass-API on SQL Database.

Underpass-API aim to be a [Overpass-API](https://github.com/drolbr/Overpass-API) compatible engine built upon [converter](https://github.com/teritorio/overpass_parser-rb) from Overpass Language to SQL.

## Prepare the data

Folow the instruction of one of the backends:
* DuckDB/Spatial, Quackosm schema

## Run the server

Install dependencies
```
bundle
```

Run the HTTP server
```
DB=landes_nofilter_noclip_compact.parquet
bundle exec rackup
```
