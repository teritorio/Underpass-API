use crate::backend::BackendType;

#[tokio::main]
async fn init_async() -> () {
    let dialect = BackendType::new(false).await;

    dialect.init().await;
}

pub fn init() {
    init_async();
}
