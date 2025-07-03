use overpass_parser_rust::{
    overpass_parser::parse_query,
    sql_dialect::{duckdb::duckdb::Duckdb, sql_dialect::SqlDialect},
};
use wasm_bindgen::prelude::*;

const VIEW: &str = "
INSTALL 'spatial';
LOAD 'spatial';

CREATE OR REPLACE TEMP VIEW node AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id < 'o';

CREATE OR REPLACE TEMP VIEW way AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'w';

CREATE OR REPLACE TEMP VIEW relation AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}' WHERE feature_id > 'o' AND feature_id < 's';

CREATE OR REPLACE TEMP VIEW nwr AS
SELECT split_part(feature_id, '/', 2)::bigint AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, feature_id[1] AS osm_type FROM '#{parquet}';

CREATE OR REPLACE TEMP VIEW area AS
SELECT split_part(feature_id, '/', 2)::bigint + CASE feature_id[1] WHEN 'r' THEN 3600000000 ELSE 0 END AS id, NULL::int AS version, NULL::timestamp AS created, NULL::int AS changeset, NULL::int AS uid, tags, NULL::bigint[] AS nodes, NULL::json AS members, geometry AS geom, CASE feature_id[1] WHEN 'w' THEN 'w' ELSE 'a' END AS osm_type FROM '#{parquet}' wHERE feature_id > 'm' AND list_contains(['POLYGON', 'MULTIPOLYGON'], ST_GeometryType(geometry));
";

#[wasm_bindgen]
pub fn prepare(parquet: &str) -> String {
    VIEW.replace("#{parquet}", parquet)
}

#[wasm_bindgen]
pub async fn query(query: &str) -> Result<String, String> {
    match parse_query(query) {
        Ok(request) => Ok(request.to_sql(
            &(Box::new(Duckdb) as Box<dyn SqlDialect + Send + Sync>),
            "4326",
            None,
        )),
        Err(e) => Err(e.to_string()),
    }
}

// #[wasm_bindgen]
// pub async fn format_result(row: Vec<String>) -> String {
//     let json = row.join(",\n");
//     json!({
//         "version": 0.6,
//         "generator": "underpass",
//         "osm3s": {
//             "copyright": "The data included in this document is from www.openstreetmap.org. The data is made available under ODbL."
//         },
//         "elements": ["[JSON]"],
//     }).to_string().replace("\"[JSON]\"", &json)
// }
