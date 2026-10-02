# DEXTR Commander

DEXTR Commander is a self-hosted Rust MCP control plane for controlled, auditable interaction with Linux hosts.

It provides MCP-native command execution and file access while keeping the host execution boundary explicit. It is designed for engineers building local or remotely mediated AI-agent infrastructure.

> **Security boundary:** DEXTR Commander is not a sandbox. `execute_command` has the privileges of the service account. Do not expose an unrestricted instance to an untrusted network.

## Why DEXTR Commander

- **Self-hosted** — the execution component runs on infrastructure you control.
- **Rust-native** — no Python or Node.js runtime is required for the core server.
- **MCP-native** — stdio and Streamable HTTP transports.
- **Small surface** — the current tool surface is intentionally explicit.
- **Auditable** — source, security policy, deployment examples, and validation scripts are public.
- **Deterministic boundary** — the operating-system account and deployment policy define the host authority.

## What it is not

DEXTR Commander is not:
- a sandbox or VM;
- a privilege-escalation mechanism;
- an authorization system by itself;
- a public Internet shell;
- a replacement for operating-system security controls.

## Architecture

### Local

```text
MCP Client
    |
    | stdio
    v
DEXTR Commander
    |
    +--> command execution
    +--> file access
    |
    v
Linux host
```

### Recommended remote deployment

```text
MCP Client
    |
    v
DEXTR Gateway
    |
    +-- authentication
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

The gateway is a security boundary. The reference HTTP server intentionally binds to loopback.

## 60-second quick start

Requirements: a stable Rust toolchain and a Linux host for execution.

```bash
git clone https://github.com/DEXTR-GROUP/DEXTR-COMMANDER.git
cd DEXTR-COMMANDER
cargo build --release
```

Run the stdio server:

```bash
./target/release/dextr-commander
```

Run the validation suite:

```bash
cargo fmt --check
cargo check
cargo test
cargo clippy --all-targets --all-features -- -D warnings
cargo build --release
bash scripts/security-audit.sh
```

## MCP transports

### Stdio

Configure your MCP client to launch:

```text
/absolute/path/to/target/release/dextr-commander
```

The server reads protocol messages from stdin and writes protocol responses to stdout. Diagnostics are written to stderr.

### Streamable HTTP

```bash
cargo build --release --bin dextr-http
./target/release/dextr-http
```

Reference endpoint:

```text
http://127.0.0.1:8787/mcp
```

Remote access requires an explicit authentication and authorization design. See [MCP integration](docs/MCP.md), [security model](docs/SECURITY.md), and [SECURITY.md](SECURITY.md).

## Current MCP tools

| Tool | Function |
|---|---|
| `execute_command` | Execute a host command with the service account's privileges |
| `read_file` | Read a file available to the service account |

Because these operations can expose or modify host state, deployments must apply least privilege and explicit access controls.

## Deployment

A reference systemd unit is provided:

```bash
sudo install -m 0755 target/release/dextr-http /usr/local/bin/dextr-http
sudo install -m 0644 systemd/dextr-http.service /etc/systemd/system/dextr-http.service
sudo systemctl daemon-reload
sudo systemctl enable --now dextr-http.service
```

Review the unit and security model before changing the network boundary.

## Security

The repository includes:
- `SECURITY.md` for security policy and secret handling;
- `docs/SECURITY.md` for the threat model and trust boundaries;
- `scripts/security-audit.sh` for repository secret auditing;
- a hardened systemd example.

Before any public or remote deployment, review authentication, authorization, rate limiting, replay protection, command policy, file-access policy, and service-account privileges.

## Установка «из коробки»

Для обычного пользователя предусмотрен установщик:

```bash
chmod +x install.sh
sudo ./install.sh
```

Он создаёт системного пользователя, каталоги DEXTR Commander, устанавливает программу и системную службу, включает автоматический запуск и проверяет результат.

Подробная инструкция: [Установка](docs/INSTALL.md).

Для разработчиков остаётся установка из исходников через Cargo.

## Remote connection

For remote MCP use, see [Remote Connection](docs/REMOTE-CONNECTION.md) and [Deployment](docs/DEPLOYMENT.md).

The public documentation describes the real connection models, including private Tailscale networking and an authenticated gateway. Production hostnames and paths should be published when they are part of the supported deployment; credentials and node secrets must remain outside Git.

Authentication and authorization are documented separately:
- [Authentication](docs/AUTHENTICATION.md)
- [Authorization](docs/AUTHORIZATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Documentation

- [Roadmap](ROADMAP.md)
- [Architecture](docs/ARCHITECTURE.md)
- [MCP integration](docs/MCP.md)
- [Security model](docs/SECURITY.md)
- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## Project status

Version **0.1.0** is the initial public release of the Rust MCP core and Streamable HTTP transport.

The public roadmap tracks the work required for a production-grade remote control plane. In particular, remote exposure hardening is intentionally treated as separate work rather than implied by the existence of an HTTP transport.

## Contributing

Contributions are welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md) and keep security-sensitive changes explicit and testable.

## License

Apache License 2.0. See [LICENSE](LICENSE).
