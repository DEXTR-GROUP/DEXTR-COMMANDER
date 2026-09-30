# Architecture

DEXTR Commander is deliberately small. The project separates MCP transport from host execution.

## Components

### Stdio server

`src/main.rs` implements the minimal JSON-RPC/MCP stdio path. It reads one JSON request per line and writes one JSON response per line.

### Streamable HTTP server

`src/bin/dextr-http.rs` uses the Rust MCP SDK and Axum to expose Streamable HTTP at `/mcp`. The reference binding is loopback-only on `127.0.0.1:8787`.

### Execution layer

The server exposes two host operations:
- execute a shell command;
- read a UTF-8 file.

The execution layer is not a sandbox. Operating-system permissions remain the primary security boundary.

## Deployment boundary

A production deployment should place an authenticated and authorized network boundary in front of the HTTP transport. A tunnel can provide HTTPS transport, but a tunnel alone does not turn unrestricted shell execution into a sandbox or authorization system.
