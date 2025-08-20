use futures::executor::block_on;

use crate::backend::BackendType;

async fn init_async() -> () {
    let dialect = BackendType::new().await;

    dialect.init().await;
}

pub fn init() {
    block_on(init_async());
}
