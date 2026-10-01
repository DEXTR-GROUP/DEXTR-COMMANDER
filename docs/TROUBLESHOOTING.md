# Troubleshooting

## Endpoint unreachable

Check DNS/hostname resolution, Tailscale connectivity, gateway availability, local listener, and firewall policy.

```bash
systemctl is-active dextr-http.service
ss -lntp | grep 8787
```

## Remote client cannot connect

The reference server binds to 127.0.0.1:8787. A remote client must use the documented gateway or private-network path.

## Authentication fails

Check client identity, credential validity, authorization-code expiry/consumption, gateway logs, and time synchronization. Never publish credentials in an issue.

## Authorization fails

Authentication and authorization are separate. Check the deployment authorization policy.

## Command execution fails

Check service account, OS permissions, command policy, working directory, executable availability, and systemd restrictions.

```bash
journalctl -u dextr-http.service --no-pager -n 100
```

## File access fails

Check requested path, service-account permissions, path authorization, and systemd filesystem restrictions.

## Security incident

Revoke or rotate exposed credentials immediately, determine exposure scope, inspect logs and repository history, preserve evidence, and follow the security disclosure procedure.
