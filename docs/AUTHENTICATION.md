# Authentication

Authentication answers: who is connecting?

Remote deployments must authenticate the connecting client before granting access to host-control tools.

## Remote flow

```text
Client
  |
  v
Authentication
  |
  v
Authorization
  |
  v
DEXTR Commander
```

## Authorization codes

If an authorization-code flow is used:
- codes expire;
- codes are single-use;
- codes are never logged;
- codes are never stored in Git;
- failed attempts are rate limited.

## Tailscale

Tailscale may provide private network and node identity. Application-level MCP authorization remains required.

## Credentials

Never commit Tailscale auth keys, API tokens, client secrets, private keys, session secrets, or production environment files.
