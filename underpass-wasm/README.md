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

## Dev

Run the demo
```
yarn dev
```

Then go to http://localhost:5173/

Note, the embedded HTTP server with dev does not support the HTTP range requests to partially download Parquet files. It falls back to full download of Parquet files, obviously, that is not the expected behavior.

## Build

```
yarn build
```

Then serve the static content with an HTTP web server supporting [HTTP range requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Range_requests) to partially download Parquet files.

```
yarn serve
```

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
