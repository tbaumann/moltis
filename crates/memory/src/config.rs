use std::path::PathBuf;

/// Configuration for the memory subsystem.
#[derive(Debug, Clone)]
pub struct MemoryConfig {
    /// Path to the SQLite database file (or `:memory:` for tests).
    pub db_path: String,
    /// Directories to scan for markdown files.
    pub memory_dirs: Vec<PathBuf>,
    /// Target chunk size in tokens (approximate, counted as whitespace-split words).
    pub chunk_size: usize,
    /// Overlap between consecutive chunks in tokens.
    pub chunk_overlap: usize,
    /// Weight for vector similarity in hybrid search (0.0–1.0).
    pub vector_weight: f32,
    /// Weight for keyword/FTS similarity in hybrid search (0.0–1.0).
    pub keyword_weight: f32,
}

impl Default for MemoryConfig {
    fn default() -> Self {
        Self {
            db_path: "memory.db".into(),
            memory_dirs: vec![PathBuf::from("memory")],
            chunk_size: 400,
            chunk_overlap: 80,
            vector_weight: 0.7,
            keyword_weight: 0.3,
        }
    }
}
