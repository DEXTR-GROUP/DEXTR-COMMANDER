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

## Reporting

Do not disclose credentials, private keys, tunnel tokens, host addresses, or other sensitive deployment data in a public issue.

For suspected vulnerabilities, contact the project maintainers privately before public disclosure.
