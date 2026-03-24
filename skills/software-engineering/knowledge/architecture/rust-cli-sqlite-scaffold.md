# Rust CLI + SQLite Scaffold Pattern
Last updated: 2026-03-24
Sources: experience (helios, nyx, loki, khora, suda — all follow this pattern)

## Summary

Standard scaffold for Rust CLI tools that use SQLite for local storage. Optimized for developer tools, indexers, and automation CLIs that store structured data locally.

## Standard Crate Stack

| Purpose | Crate | Features | Notes |
|---------|-------|----------|-------|
| CLI parsing | `clap` 4.x | `derive` | Use derive API, `ValueEnum` for enums |
| Database | `rusqlite` 0.32.x | `bundled` | `bundled` compiles SQLite from source — no system dep |
| Serialization | `serde` 1.x | `derive` | For JSON output and import/export |
| JSON | `serde_json` 1.x | | |
| Timestamps | `chrono` 0.4.x | `serde` | Optional — only if you need timestamp formatting |
| Home dir | `dirs` 6.x | | For `~/.toolname/` data directory |

## Project Structure

```
tool-name/
├── Cargo.toml
├── src/
│   ├── main.rs          # CLI entry point, clap setup, command dispatch
│   ├── db.rs            # Connection, schema init, migrations
│   ├── <domain>.rs      # One module per domain (e.g., memory.rs, index.rs)
│   └── display.rs       # Output formatting (human-readable + JSON)
├── tests/
│   └── integration.rs   # CLI integration tests using TOOL_HOME env var
├── .github/
│   └── workflows/
│       └── release.yml  # v* tag trigger, 4 platform builds, tap update
├── .gitignore           # /target, Cargo.lock
└── LICENSE              # MIT
```

## Database Module Pattern

```rust
use std::path::PathBuf;

pub fn data_dir() -> PathBuf {
    // CRITICAL: Always support env var override for testing
    if let Ok(dir) = std::env::var("TOOL_HOME") {
        return PathBuf::from(dir);
    }
    let home = dirs::home_dir().expect("Could not determine home directory");
    home.join(".toolname")
}

pub fn connect() -> Result<Connection> {
    let dir = data_dir();
    std::fs::create_dir_all(&dir).expect("Could not create data directory");
    let conn = Connection::open(dir.join("toolname.db"))?;
    conn.execute_batch("PRAGMA journal_mode=WAL;")?;
    conn.execute_batch("PRAGMA foreign_keys=ON;")?;
    initialize(&conn)?;
    Ok(conn)
}
```

Key points:
- **WAL mode** for concurrent reads
- **Foreign keys ON** explicitly (SQLite has them off by default)
- **Env var override** for the data directory — this is what makes testing isolated
- **create_dir_all** on first connect — no separate `init` command needed

## Integration Test Pattern

```rust
struct TestEnv {
    dir: PathBuf,
}

impl TestEnv {
    fn new(name: &str) -> Self {
        let dir = std::env::temp_dir()
            .join(format!("tool-test-{name}-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        Self { dir }
    }

    fn run(&self, args: &[&str]) -> std::process::Output {
        Command::new(env!("CARGO_BIN_EXE_toolname"))
            .args(args)
            .env("TOOL_HOME", &self.dir)
            .output()
            .expect("failed to run tool")
    }
}

impl Drop for TestEnv {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.dir);
    }
}
```

Each test gets a fresh temp directory and isolated database. Cleanup is automatic via Drop.

## FTS5 Full-Text Search

When the tool needs search, use SQLite FTS5:

```sql
CREATE VIRTUAL TABLE items_fts USING fts5(
    name, description, content,
    content=items, content_rowid=id
);
```

Keep FTS in sync with triggers on INSERT, UPDATE, DELETE. The triggers insert into the FTS table with special `'delete'` commands for updates/deletes.

## Output Pattern

Every read command should support `--json` (global flag via clap). The display module has two paths:
- Human-readable: tables, detail views
- JSON: `serde_json::to_string_pretty` for programmatic consumption by agents

## Release Workflow

Standard 4-platform build matrix:
- `x86_64-apple-darwin` (macOS Intel)
- `aarch64-apple-darwin` (macOS Apple Silicon)
- `x86_64-unknown-linux-gnu` (Linux amd64)
- `aarch64-unknown-linux-gnu` (Linux arm64, needs cross-compilation)

Linux arm64 cross-compilation requires:
```yaml
- name: Install cross-compilation tools
  if: matrix.target == 'aarch64-unknown-linux-gnu'
  run: |
    sudo apt-get update
    sudo apt-get install -y gcc-aarch64-linux-gnu
    echo "CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc" >> $GITHUB_ENV
```

## Related Topics

- [Rust CLI Architecture Patterns](rust-cli-patterns.md) — API wrapper CLIs (different pattern)
- [Rust Dependency Management](../tooling/rust-dependency-management.md)
