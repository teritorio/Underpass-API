use axum::Form;
use axum::body::Body;
use axum::extract::{Query, State};
use axum::http::{StatusCode, header};
use axum::response::Response;
use serde::Deserialize;
use serde_json::json;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::Mutex;

use crate::backend::BackendType;

async fn query(
    query: &str,
    backend: Arc<Mutex<Box<BackendType>>>,
) -> Result<Response<Body>, axum::http::Error> {
    let mut backend = backend.lock().await;
    match backend.parse_query(query) {
        Ok(sql) => {
            let dialect = backend.name();
            let json = backend.exec(sql).await.join(",\n");

            let body = json!({
                "version": 0.6,
                "generator": "underpass",
                "osm3s": {
                    "backend": dialect,
                    "query": query,
                    "copyright": "The data included in this document is from www.openstreetmap.org. The data is made available under ODbL."
                },
                "elements": ["[JSON]"],
            }).to_string().replace("\"[JSON]\"", &json);

            Response::builder()
                .status(StatusCode::OK)
                .header(header::CONTENT_TYPE, "application/json")
                .body(Body::from(body))
        }
        Err(error) => {
            let html = format!(
                "<html>
             <body>
             <p><strong style=\"color:#FF0000\">Error</strong>: <pre>{error}</pre></p>
             </body>
             </html>"
            );

            Response::builder()
                .status(StatusCode::BAD_REQUEST)
                .body(Body::from(html))
        }
    }
}

#[axum::debug_handler]
pub async fn query_get(
    State(backend): State<Arc<Mutex<Box<BackendType>>>>,
    Query(params): Query<HashMap<String, String>>,
) -> Response<Body> {
    match params.get("data") {
        Some(data) => query(data, backend).await.unwrap(),
        None => Response::builder()
            .status(StatusCode::BAD_REQUEST)
            .body(Body::from("Missing 'data' parameter in query"))
            .unwrap(),
    }
}

#[derive(Deserialize)]
pub struct Post {
    data: Option<String>,
}

#[axum::debug_handler]
pub async fn query_post(
    State(backend): State<Arc<Mutex<Box<BackendType>>>>,
    Form(form): Form<Post>,
) -> Response<Body> {
    match form.data {
        Some(data) => query(&data, backend).await.unwrap(),
        None => Response::builder()
            .status(StatusCode::BAD_REQUEST)
            .body(Body::from("Missing 'data' parameter in the body form"))
            .unwrap(),
    }
}
