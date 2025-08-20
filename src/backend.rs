#[cfg(feature = "duckdb")]
use crate::duckdb_quackosm;
#[cfg(feature = "postgres")]
use crate::postgres_osmosis;

pub trait Backend {
    fn name(&self) -> String;

    async fn init(&self) -> ();

    fn parse_query(&self, query: &str) -> Result<String, String>;

    async fn exec(&mut self, query: String) -> Vec<String>;
}

pub enum BackendType {
    #[cfg(feature = "postgres")]
    PostgresOsmosis(postgres_osmosis::PostgresOsmosis),
    #[cfg(feature = "duckdb")]
    DuckdbQuackosm(duckdb_quackosm::DuckdbQuackosm),
}

impl BackendType {
    pub async fn new(with_view: bool) -> Self {
        match std::env::var("BACKEND") {
            #[cfg(feature = "postgres")]
            Ok(backend) if backend == "PostgresOsmosis" => BackendType::PostgresOsmosis(
                postgres_osmosis::PostgresOsmosis::new(
                    std::env::var("DB")
                        .expect("DB env var is required")
                        .as_str(),
                        with_view,
                )
                .await,
            ),
            #[cfg(feature = "duckdb")]
            Ok(backend) if backend == "DuckdbQuackosm" => {
                BackendType::DuckdbQuackosm(duckdb_quackosm::DuckdbQuackosm::new(
                    std::env::var("DB")
                        .expect("DB env var is required")
                        .as_str(),
                        with_view,
                ))
            }
            _ => panic!(
                "Env var BACKEND should define a valid backend: {:?}.",
                [
                    #[cfg(feature = "postgres")]
                    "PostgresOsmosis",
                    #[cfg(feature = "duckdb")]
                    "DuckdbQuackosm",
                ]
            ),
        }
    }

    pub fn name(&self) -> String {
        match self {
            #[cfg(feature = "postgres")]
            BackendType::PostgresOsmosis(backend) => backend.name(),
            #[cfg(feature = "duckdb")]
            BackendType::DuckdbQuackosm(backend) => backend.name(),
        }
    }

    pub async fn init(&self) -> () {
        match self {
            #[cfg(feature = "postgres")]
            BackendType::PostgresOsmosis(backend) => backend.init().await,
            #[cfg(feature = "duckdb")]
            BackendType::DuckdbQuackosm(backend) => backend.init().await,
        }
    }

    pub fn parse_query(&self, query: &str) -> Result<String, String> {
        match self {
            #[cfg(feature = "postgres")]
            BackendType::PostgresOsmosis(backend) => backend.parse_query(query),
            #[cfg(feature = "duckdb")]
            BackendType::DuckdbQuackosm(backend) => backend.parse_query(query),
        }
    }

    pub async fn exec(&mut self, query: String) -> Vec<String> {
        match self {
            #[cfg(feature = "postgres")]
            BackendType::PostgresOsmosis(backend) => backend.exec(query).await,
            #[cfg(feature = "duckdb")]
            BackendType::DuckdbQuackosm(backend) => backend.exec(query).await,
        }
    }
}
