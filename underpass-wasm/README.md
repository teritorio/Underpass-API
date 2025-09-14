# Underpass WASM

Aka JS/WASM Edge computing Cloud optimised Compatible Overpass Query engine.

In other word, an engin able to execute (part of) Overpass Query without the need of an Overpass-API server. Using an in browser WASM Overpass Query converter to SQL and a WASM DuckDB/QuackOSM data base relying on a remote static Parquet file produced using QuackOSM.

Yes, it works.

## Build

```
yarn build
```

## Prepare data

Folow data setup from [../src/duckdb_quackosm/README.md], but do not run the server.

## Run

Run the demo
```
yarn dev
```

Then go to http://localhost:5173/

## Reuse the lib

```bash
yarn add @teritorio/underpass
```

```ts
import Underpass from '@teritorio/underpass'

Underpass.getConnection('http://localhost:5173/data/extract_nofilter_noclip_compact.parquet', (connection: Underpass.Connection) => {
    connection.query('node[amenity=drinking_water];out;', (osm_object) => {
        console.log(osm_object);
    });
});
```

## Licence

Teritorio, Frédéric Rodrigo, 2025, AGPL.
