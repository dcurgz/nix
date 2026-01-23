use axum::extract::State;
use axum::http::StatusCode;
use axum::routing::{get, post};
use axum::{Json, Router};
use axum::response::{Html, IntoResponse};

use tower_http::services::ServeDir;

use std::collections::HashMap;
use std::net::SocketAddr;
use std::string::String;
use std::sync::{Arc, RwLock};
use std::path::{Path, PathBuf};
use std::fs;

use clap::Parser;

use itertools::Itertools;

use log::{info, warn, error};

const UNDEFINED: &str = "undefined";

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Options {
    #[arg(short, long, default_value = "127.0.0.1:8080")] 
    listen: String,
    #[arg(short, long, num_args = 2)]
    template_key: Vec<String>,
    #[arg(short, long)]
    webroot: String,
}

#[derive(Default)]
struct RouterContext {
    webroot: PathBuf,
    kv: HashMap<String, String>,
}

type RouterState = Arc<RwLock<RouterContext>>;

#[tokio::main]
async fn main() {
    let options = Options::parse();
    let addr: SocketAddr = options.listen.parse().unwrap();
  
    info!(":: weirdfi.sh server v0.1");

    let state = RouterState::default();
    state.write().unwrap().kv = options.template_key
        .into_iter()
        .tuples()
        .collect::<HashMap<_, _>>();

    let webroot = Path::new(&options.webroot);
    if ! webroot.exists() {
        error!("E: path given by --webroot ('{0}') does not exist", webroot.display());
        return;
    }

    state.write().unwrap().webroot = webroot.to_path_buf();
    info!("configured webroot ({0})", webroot.display());

    let app = Router::new()
        //.route("/", get(root).with_state(state));
        .fallback_service(ServeDir::new(webroot));

    print!("starting Axum web server on {addr} ...");
    let listener = tokio::net::TcpListener::bind(addr.to_string())
        .await
        .unwrap();
    print!("OK");
    axum::serve(listener, app).await;
}

//async fn root(
//    State(state): State<RouterState>,
//) -> impl IntoResponse {
//    let ctx = &state.read().unwrap();
//    let value = ctx.kv.get("git-rev")
//        .map(|s| s.as_str())
//        .unwrap_or_else(|| UNDEFINED);
//    let content = fs::read_to_string(ctx.webroot.join("index.html")).unwrap();
//    Html(content)
//}
