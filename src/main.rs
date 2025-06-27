use actix_web::{HttpResponse, HttpServer};
use hf_hub::{api::tokio::Api, Repo};
use mistralrs::{GGUFLoaderBuilder, TextModelBuilder};

const MODEL_ID: &str = "mradermacher/Gemma-3-Gaia-PT-BR-4b-it-i1-GGUF";

#[get("/generate")]
async fn generate() -> HttpResponse {
    let api = Api::new().unwrap();
    let quantized_model_path = api.repo(Repo::new(MODEL_ID, hf_hub::RepoType::Model)).download("Gemma-3-Gaia-PT-BR-4b-it.i1-Q4_K_M.gguf").await.unwrap();
    println!("{}", quantized_model_path);
    HttpResponse::Ok().body("Model downloaded successfully")
}

#[tokio::main]
async fn main() {
    HttpServer::new(|| {
        App::new().service(generate)
    })
    .bind("127.0.0.1:5555")?
    .run()
    .await
}
