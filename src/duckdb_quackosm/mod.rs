use duckdb::Connection;
use overpass_parser_rust::{
    overpass_parser::parse_query,
    sql_dialect::{duckdb::duckdb::Duckdb, sql_dialect::SqlDialect},
};

use crate::backend::Backend;

pub struct DuckdbQuackosm {
    dialect: Box<dyn SqlDialect + Send + Sync>,
    con: Connection,
}

impl DuckdbQuackosm {
    pub fn new(parquet: &str) -> DuckdbQuackosm {
        let con = Connection::open_in_memory().expect("Failed to connect to DuckDB database");
        let sql = std::fs::read_to_string("src/duckdb_quackosm/view.sql")
            .expect("Failed to read view.sql file")
            .replace("#{parquet}", parquet);
        con.execute_batch(&sql)
            .expect("Failed to create view from parquet file");

        DuckdbQuackosm {
            dialect: Box::new(Duckdb),
            con,
        }
    }
}

impl Backend for DuckdbQuackosm {
    fn name(&self) -> String {
        "duckdb_quackosm".to_string()
    }

    fn parse_query(&self, query: &str) -> Result<String, String> {
        match parse_query(query) {
            Ok(request) => Ok(request.to_sql(&self.dialect, "4326", None)),
            Err(e) => Err(e.to_string()),
        }
    }

    async fn exec(&mut self, sql: String) -> Vec<String> {
        let mut stmt = self.con.prepare(&sql).expect("Failed to execute SQL query");
        stmt.query_map([], |row| Ok(row.get::<usize, String>(0).unwrap()))
            .unwrap()
            .map(|result| result.ok().unwrap())
            .collect()
    }
}
