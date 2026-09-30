# Security Policy

DEXTR Commander provides host-level command execution and file access through MCP. The security boundary is the operating-system account under which the server runs.

## Critical warning

Running the HTTP server as root and exposing it to an untrusted network grants the remote MCP client effective root-level control of the host.

Do not publish an unrestricted DEXTR Commander endpoint to the public Internet.

Recommended deployment properties:
1. bind the service to loopback or a private interface;
2. use an authenticated and authorized network boundary;
3. run under a dedicated unprivileged account when root is not required;
4. restrict filesystem access where possible;
5. keep deployment credentials and tunnel configuration outside the repository;
6. audit commands and network exposure before enabling remote access.

## Secret handling

The public repository must never contain:
- API keys, access tokens, passwords, session tokens, or bearer credentials;
- private SSH/TLS/signing keys or certificate bundles;
- tunnel credentials or host-specific deployment state;
- `.env` files or equivalent secret-bearing configuration.

Run the repository audit before every public release:

```bash
./scripts/security-audit.sh
```

The audit scans every Git blob reachable from repository refs, not only the current working tree. A successful audit is evidence that the checked Git history contains no matches for the repository's configured credential patterns; it is not a substitute for revocation when a credential has ever been exposed.

If a credential is suspected to have been committed:
1. revoke or rotate it immediately;
2. determine which Git refs contained it;
3. remove the secret from reachable history;
4. re-run the audit;
5. verify the credential is no longer valid.

## Reporting

Do not disclose credentials, private keys, tunnel tokens, host addresses, or other sensitive deployment data in a public issue.

For suspected vulnerabilities, contact the project maintainers privately before public disclosure.
