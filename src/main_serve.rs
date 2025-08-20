use axum::Router;
use axum::body::Body;
use axum::extract::Request;
use axum::http::{Method, Uri};
use axum::middleware::Next;
use axum::response::Response;
use axum::routing::{get, post};
use backend::BackendType;
use query::{query_get, query_post};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Mutex;
use tower::ServiceBuilder;
use tower_http::cors::{Any, CorsLayer};
use tower_http::{classify::ServerErrorsFailureClass, trace::TraceLayer};
use tracing::Span;

use crate::{backend, query};

struct RequestUri(Uri);
impl Clone for RequestUri {
    fn clone(&self) -> Self {
        Self(self.0.clone())
    }
}

async fn uri_middleware(request: Request<Body>, next: Next) -> Response {
    let uri = request.uri().clone();
    let mut response = next.run(request).await;
    response.extensions_mut().insert(RequestUri(uri));
    response
}

#[tokio::main]
async fn serve_async() -> () {
    let dialect = BackendType::new(true).await;

    let cors_layer = CorsLayer::new()
        .allow_origin(Any) // Open access to selected route
        .allow_methods([Method::GET, Method::POST]);

    let trace = TraceLayer::new_for_http()
        .on_response(|response: &Response, latency: Duration, _span: &Span| {
            println!(
                "{:?} {:?} {:?}",
                response
                    .extensions()
                    .get::<RequestUri>()
                    .map(|r| &r.0)
                    .unwrap(),
                response.status(),
                latency
            )
        })
        .on_failure(
            |error: ServerErrorsFailureClass, _latency: Duration, _span: &Span| {
                println!("{error:?}");
            },
        );

    let app = Router::new()
        .route("/interpreter", get(query_get))
        .route("/interpreter", post(query_post))
        .with_state(Arc::new(Mutex::new(Box::new(dialect))))
        .layer(ServiceBuilder::new().layer(cors_layer))
        .layer(axum::middleware::from_fn(uri_middleware))
        .layer(trace);

    let bind = "0.0.0.0:9292";
    let listener = tokio::net::TcpListener::bind(bind).await.unwrap();
    println!("Server running on http://{bind}");
    axum::serve(listener, app).await.unwrap();
}

pub fn serve() {
    serve_async();
}
