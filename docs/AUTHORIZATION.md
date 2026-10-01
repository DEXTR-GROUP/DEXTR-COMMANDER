# Authorization

Authorization answers: what is this authenticated client allowed to do?

## Required policy

A remote deployment should explicitly define:
- trusted clients;
- allowed tools;
- permitted commands;
- readable filesystem paths;
- destructive-operation policy;
- rate limits;
- request limits;
- audit requirements.

## Command execution

The current execute_command primitive is intentionally powerful. Until a command policy is implemented, it must be treated as host-level authority for the service account.

## File access

The read_file primitive can expose credentials and sensitive host data. Production deployments should apply path authorization in addition to OS permissions.

## Least privilege

```text
Identity
   |
   v
Allowed tools
   |
   v
Allowed operations
   |
   v
Allowed resources
```

## Audit

Security-sensitive requests should be attributable to an authenticated identity and produce auditable events without recording secrets.
