use overpass_parser_rust::{
    overpass_parser::parse_query,
    sql_dialect::{postgres::postgres::Postgres, sql_dialect::SqlDialect},
};
use serde_json::Value;
use tokio_postgres::{Client, NoTls};

use crate::backend::Backend;

pub struct PostgresOsmosis {
    dialect: Box<dyn SqlDialect + Send + Sync>,
    con: Client,
}

impl PostgresOsmosis {
    async fn exec_sql_file(con: &Client, file_path: &str) {
        let sql = std::fs::read_to_string(file_path).expect("Failed to read {file_path} file");

        match con.batch_execute(&sql).await {
            Ok(_) => {}
            Err(e) => panic!("Failed to execute {file_path}: {e}"),
        };
    }

    pub async fn new(db: &str, with_view: bool) -> PostgresOsmosis {
        let (con, connection) = tokio_postgres::connect(db, NoTls).await.unwrap();
        tokio::spawn(async move {
            if let Err(e) = connection.await {
                panic!("Connection error: {e}");
            }
        });

        if with_view {
            Self::exec_sql_file(&con, "src/postgres_osmosis/view.sql").await;
        }

        // TODO @dialect = OverpassParser::SqlDialect::Postgres.new(postgres_escape_literal: ->(s) { @@con.escape_literal(s) })
        PostgresOsmosis {
            dialect: Box::new(Postgres::default()),
            con,
        }
    }
}

impl Backend for PostgresOsmosis {
    fn name(&self) -> String {
        "postgres_osmosis".to_string()
    }

    async fn init(&self) -> () {
        Self::exec_sql_file(&self.con, "src/postgres_osmosis/init.sql").await;
    }

    fn parse_query(&self, query: &str) -> Result<String, String> {
        match parse_query(query) {
            Err(e) => Err(e.to_string()),
            Ok(request) => {
                let finalizer = "
SELECT
    results.id,
    results.version,
    results.tstamp::timestamp with time zone AS created,
    results.changeset_id AS changeset,
    users.name AS user,
    results.user_id AS uid,
    NULL::jsonb tags,
    results.nodes,
    NULL::jsonb AS members,
    results.geom,
    results.osm_type
FROM
    {{query}} AS results
    LEFT JOIN users ON
        users.id = results.user_id
    LEFT JOIN relation_members ON
        results.osm_type = 'r' AND
        relation_members.relation_id = results.id
GROUP BY
    results.id,
    results.version,
    results.tstamp,
    results.changeset_id,
    users.name,
    results.user_id,
    results.tags,
    results.nodes,
    results.geom,
    results.osm_type
";
                Ok(request.to_sql(&*self.dialect, "4326", Some(finalizer)))
            }
        }
    }

    async fn exec(&mut self, sql: String) -> Vec<String> {
        let mut sql = sql.to_string();
        if sql.starts_with("SET statement_timeout") {
            let (timeout, s) = sql.split_once(';').unwrap();
            self.con
                .execute(&timeout.to_string(), &[])
                .await
                .expect("Failed to set statement timeout");
            sql = s.to_string();
        }
        self.con
            .query(&sql.to_string(), &[])
            .await
            .expect("Failed to execute SQL query")
            .iter()
            .filter_map(|row| {
                let json_value: Option<Value> = row.get(0);
                json_value.map(|v| v.to_string().replace("+00:00", "Z"))
            })
            .collect()
    }
}
