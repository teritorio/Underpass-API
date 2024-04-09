# Underpass-API

An Overpass-API on SQL Database.

Underpass-API aim to be a [Overpass-API](https://github.com/drolbr/Overpass-API) compatible engine built upon [converter](https://github.com/teritorio/overpass_parser-rb) from Overpass Language to SQL.

## Prepare the data

Tow SQL backends are available.

### Postgres/PostGIS
See overpass_parser-rb doc.

### DuckDB/Spatial, Quackosm schema

Install Quackosm
```
python -m venv venv
source venv/bin/activate
pip install quackosm[cli]
```

Prepare the data
```
quackosm landes.osm.pbf
mv landes_nofilter_noclip_compact.geoparquet landes_nofilter_noclip_compact.parquet
```

## Run the server

Install dependencies
```
bundle
```

Run the HTTP server
```
DB=landes_nofilter_noclip_compact.parquet bundle exec rackup
```
