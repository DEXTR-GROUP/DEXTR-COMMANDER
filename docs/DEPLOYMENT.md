# Deployment

## Build

```bash
cargo build --release
```

## Service account

Run DEXTR Commander under a dedicated least-privilege OS account. Do not run it as root unless root authority is explicitly required and reviewed.

## HTTP binding

The reference HTTP server binds to:

`127.0.0.1:8787/mcp`

Remote exposure should use a separate network/security boundary.

## Systemd

```bash
sudo install -m 0755 target/release/dextr-http /usr/local/bin/dextr-http
sudo install -m 0644 systemd/dextr-http.service /etc/systemd/system/dextr-http.service
sudo systemctl daemon-reload
sudo systemctl enable --now dextr-http.service
```

Inspect with:

```bash
systemctl status dextr-http.service
journalctl -u dextr-http.service
```

## Production topology

```text
Internet / MCP client
        |
        v
Authenticated gateway
        |
Tailscale / private LAN
        |
        v
      wmw
        |
        v
DEXTR Commander
```

Production documentation should state the canonical MCP hostname, path, network path, authentication, authorization, service account, logging, health checks, and rollback procedure.

Production secrets remain outside Git.

## Verification

```bash
systemctl is-active dextr-http.service
ss -lntp
journalctl -u dextr-http.service --no-pager -n 100
```

Then perform MCP initialization and a non-destructive test such as hostname through the authorized client.
