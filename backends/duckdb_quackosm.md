# DuckDB/Spatial, Quackosm schema

## Install Quackosm
```
python -m venv venv
source venv/bin/activate
pip install quackosm[cli]
```

## Prepare the data
```
quackosm landes.osm.pbf
mv landes_nofilter_noclip_compact.geoparquet landes_nofilter_noclip_compact.parquet
```

## Run the server

Run the HTTP server
```
DB=landes_nofilter_noclip_compact.parquet bundle exec rackup
```
