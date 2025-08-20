use std::env;

mod main_init;
mod main_serve;
mod backend;
#[cfg(feature = "duckdb")]
mod duckdb_quackosm;
#[cfg(feature = "postgres")]
mod postgres_osmosis;
mod query;

fn main() {
    let args: Vec<String> = env::args().collect();
    let action = args.get(1).expect("Usage: [init|serve]").to_string();

    match action.as_str() {
        "init" => main_init::init(),
        "serve" => main_serve::serve(),
        _ => panic!("Invalid action. Use 'init' or 'serve'."),
    }
}
