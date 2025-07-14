# Underpass WASM

Aka JS/WASM Edge computing Cloud optimised Compatible Overpass Query engine.

In other word, an engin able to execute (part of) Overpass Query without the need of an Overpass-API server. Using an in browser WASM Overpass Query converter to SQL and a WASM DuckDB/QuackOSM data base relying on a remote static Parquet file produced using QuackOSM.

Yes, it works.

## How to use it

Have a remote OpenStreetMap Parquet file produced by [QuackOSM](https://github.com/kraina-ai/quackosm).


```bash
yarn add @teritorio/underpass
```

```ts
import Underpass from '@teritorio/underpass'

Underpass.getConnection('http://localhost:5173/extract_nofilter_noclip_compact.parquet', (connection: Underpass.Connection) => {
    connection.query('node[amenity=drinking_water];out;', (osm_object) => {
        console.log(osm_object);
    });
});
```

## Dev

Build
```
yarn build
yarn dev
```

## Licence

Teritorio, Frédéric Rodrigo, 2025, AGPL.
