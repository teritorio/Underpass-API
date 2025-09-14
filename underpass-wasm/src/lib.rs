use overpass_parser_rust::{
    overpass_parser::parse_query,
    sql_dialect::{duckdb::duckdb::Duckdb, sql_dialect::SqlDialect},
};
use wasm_bindgen::prelude::*;

const VIEW: &str = include_str!("../../src/duckdb_quackosm/view.sql");

#[wasm_bindgen]
pub fn prepare(parquet: &str) -> String {
    VIEW.replace("#{parquet}", parquet)
}

#[wasm_bindgen]
pub async fn query(query: &str) -> Result<String, String> {
    match parse_query(query) {
        Ok(request) => Ok(request.to_sql(
            &Duckdb as &(dyn SqlDialect + Send + Sync),
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
