use axum::extract::State;
use axum::http::StatusCode;
use axum::routing::{get, post};
use axum::{Json, Router};

use std::collections::HashMap;
use std::net::SocketAddr;
use std::string::String;
use std::sync::{Arc, RwLock};

use clap::Parser;

use itertools::Itertools;

const UNDEFINED: &str = "undefined";

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Options {
    #[arg(short, long, default_value = "127.0.0.1:8080")] 
    listen: String,
    #[arg(short, long, num_args = 2)]
    key: Vec<String>,
}

#[derive(Default)]
struct RouterContext {
    kv: HashMap<String, String>,
}

type RouterState = Arc<RwLock<RouterContext>>;

#[tokio::main]
async fn main() {
    let options = Options::parse();
    let addr: SocketAddr = options.listen.parse().unwrap();
  
    println!(":: weirdfi.sh server v0.1");

    let state = RouterState::default();
    state.write().unwrap().kv = options.key
        .into_iter()
        .tuples()
        .collect::<HashMap<_, _>>();
    let app = Router::new()
        .route("/", get(root).with_state(state));

    print!("starting Axum web server on {addr} ... ");
    let listener = tokio::net::TcpListener::bind(addr.to_string())
        .await
        .unwrap();
    println!("OK");
    axum::serve(listener, app).await;
}

async fn root(
    State(state): State<RouterState>,
) -> String {
    let kv = &state.read().unwrap().kv;
    let value = kv.get("git-rev")
        .map(|s| s.as_str())
        .unwrap_or_else(|| UNDEFINED);
    format!("good morning from weirdfi.sh! Git rev is {value}")
}
