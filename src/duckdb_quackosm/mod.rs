use duckdb::Connection;
use overpass_parser_rust::{
    overpass_parser::parse_query,
    sql_dialect::{duckdb::duckdb::Duckdb, sql_dialect::SqlDialect},
};

use crate::backend::Backend;

pub struct DuckdbQuackosm {
    parquet: String,
    dialect: Box<dyn SqlDialect + Send + Sync>,
    con: Connection,
}

impl DuckdbQuackosm {
    fn exec_sql_file(con: &Connection, file_path: &str, parquet: &str) {
        let sql = std::fs::read_to_string(file_path)
            .expect(format!("Failed to read {file_path}").as_str())
            .replace("#{parquet}", parquet);
        con.execute_batch(&sql)
            .expect(format!("Failed to execute sql from file {file_path}").as_str());
    }

    pub fn new(parquet: &str, with_view: bool) -> DuckdbQuackosm {
        let con = Connection::open_in_memory().expect("Failed to connect to DuckDB database");

        if with_view {
            Self::exec_sql_file(&con, "src/duckdb_quackosm/view.sql", parquet);
        }

        DuckdbQuackosm {
            parquet: parquet.to_string(),
            dialect: Box::new(Duckdb),
            con,
        }
    }
}

impl Backend for DuckdbQuackosm {
    fn name(&self) -> String {
        "duckdb_quackosm".to_string()
    }

    async fn init(&self) -> () {
        Self::exec_sql_file(
            &self.con,
            "src/duckdb_quackosm/init.sql",
            self.parquet.as_str(),
        );
    }

    fn parse_query(&self, query: &str) -> Result<Vec<String>, String> {
        match parse_query(query) {
            Ok(request) => Ok(request.to_sql(&*self.dialect, "4326", None)),
            Err(e) => Err(e.to_string()),
        }
    }

    async fn exec(&mut self, sqls: Vec<String>) -> Vec<String> {
        let mut sqls = sqls;
        let last_sql = sqls.pop().expect("No SQL queries to execute");
        self.con
            .execute_batch(sqls.join("\n").as_str())
            .expect("Failed to execute SQL query");
        let mut stmt = self
            .con
            .prepare(&last_sql)
            .expect("Failed to execute SQL query");
        stmt.query_map([], |row| Ok(row.get::<usize, String>(0).unwrap()))
            .unwrap()
            .map(|result| result.ok().unwrap())
            .collect()
    }
}
