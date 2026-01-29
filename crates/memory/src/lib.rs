//! Memory management: markdown files → chunked → embedded → hybrid search in SQLite.

pub mod chunker;
pub mod config;
pub mod embeddings;
pub mod embeddings_openai;
pub mod manager;
pub mod schema;
pub mod search;
pub mod store;
pub mod store_sqlite;
pub mod tools;
