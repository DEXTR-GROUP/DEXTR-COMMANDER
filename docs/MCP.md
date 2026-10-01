# MCP Integration

DEXTR Commander exposes host-control capabilities through the Model Context Protocol (MCP).

## Transports

### Stdio

The stdio server is the simplest deployment model for a local MCP client:

```text
MCP client
   |
   | stdin/stdout
   v
dextr-commander
   |
   +--> command execution
   +--> file access
```

Build:

```bash
cargo build --release
```

Run:

```bash
./target/release/dextr-commander
```

The process uses stdout for the protocol and stderr for diagnostics.

### Streamable HTTP

The reference HTTP binary is:

```bash
cargo build --release --bin dextr-http
./target/release/dextr-http
```

The reference configuration binds to loopback at `127.0.0.1:8787/mcp`.

Do not treat the reference HTTP server as an Internet-facing security boundary. Remote deployment requires an authenticated and authorized gateway or an equivalent network/security control plane.

## Tools

The current MCP surface includes:

| Tool | Purpose | Security significance |
|---|---|---|
| `execute_command` | Execute a host command | Potentially full authority of the service account |
| `read_file` | Read a host file | Potential disclosure of local data and secrets |

The exact authority is determined by the operating-system account and deployment policy.

## Local verification

A minimal validation flow:

```bash
cargo fmt --check
cargo check
cargo test
cargo clippy --all-targets --all-features -- -D warnings
cargo build --release
bash scripts/security-audit.sh
```

## Integration principle

An MCP client should be treated as an untrusted caller until authentication and authorization have established otherwise.

For remote deployments, use:

```text
MCP Client
    |
    v
Authenticated Gateway
    |
    +-- authorization
    +-- rate limiting
    +-- replay protection
    +-- request auditing
    |
    v
DEXTR Commander
    |
    v
Linux host
```

## Security invariant

Never expose an unrestricted shell-backed DEXTR Commander endpoint to an untrusted network.
