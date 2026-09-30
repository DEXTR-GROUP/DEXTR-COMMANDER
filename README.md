# DEXTR Commander

DEXTR Commander is a lightweight Rust implementation of an MCP server for controlled command execution and file access on a Linux host.

## Features

- Rust implementation;
- no Node.js or Python runtime required;
- MCP stdio transport;
- MCP Streamable HTTP transport;
- `execute_command` tool;
- `read_file` tool;
- small deployment footprint;
- systemd service example.

## Security

DEXTR Commander is an execution component, not a sandbox. The `execute_command` tool runs commands through the host shell with the privileges of the service process. If the service runs as root, commands have root privileges.

Do not expose the HTTP endpoint directly to the public Internet without an explicit access-control design. A public MCP endpoint backed by unrestricted shell execution is equivalent to remote administrative access to the host.

The repository does not contain credentials, Tailscale state, ChatGPT configuration, or deployment-specific secrets.

## Build

Requires a recent stable Rust toolchain.

```bash
cargo build --release
```

## Stdio MCP

Run `target/release/dextr-commander`. The server reads JSON-RPC requests from stdin and writes responses to stdout. Diagnostics are written to stderr.

Example MCP configuration:

```json
{
  "mcpServers": {
    "dextr-commander": {
      "command": "/absolute/path/to/target/release/dextr-commander"
    }
  }
}
```

## Streamable HTTP MCP

Build and run:

```bash
cargo build --release --bin dextr-http
./target/release/dextr-http
```

The reference server binds to `127.0.0.1:8787/mcp` and is intentionally loopback-only. Put authentication and a trusted network boundary in front of it before remote exposure.

Example systemd installation:

```bash
sudo install -m 0755 target/release/dextr-http /usr/local/bin/dextr-http
sudo install -m 0644 systemd/dextr-http.service /etc/systemd/system/dextr-http.service
sudo systemctl daemon-reload
sudo systemctl enable --now dextr-http.service
```

## Architecture

```text
MCP client
   |
   +-- stdio --------------------> dextr-commander
   |
   +-- Streamable HTTP /mcp -----> dextr-http
                                      |
                                      +--> shell
                                      +--> filesystem
```

See `docs/ARCHITECTURE.md` and `SECURITY.md`.

## Project status

Version 0.1.0 is the initial public release of the Rust MCP core and Streamable HTTP transport.

## License

Apache License 2.0. See `LICENSE`.