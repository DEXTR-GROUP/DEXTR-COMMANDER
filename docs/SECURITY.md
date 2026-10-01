# Security Model

DEXTR Commander provides host-level command execution and file access. Its primary security boundary is the operating-system account and the deployment boundary around the MCP server.

## Threat model

| Threat | Consequence | Required control |
|---|---|---|
| Unauthenticated remote command execution | Host compromise | Authentication and authorization gateway |
| Privileged service account | Privilege escalation impact | Dedicated least-privilege account |
| Credential disclosure through file access | Secret compromise | File authorization and deployment isolation |
| Authorization-code replay | Session/account takeover | Single-use codes and expiry |
| Request flooding | Resource exhaustion | Rate limiting and bounded request processing |
| Arbitrary shell interpretation | Command injection / unintended execution | Explicit command policy or restricted executor |
| Replay of valid requests | Duplicate or unauthorized actions | Request freshness and replay protection |
| Excessive file access | Data exfiltration | Path policy, allowlists, and OS permissions |

## Trust boundaries

The recommended remote architecture is:

```text
Untrusted MCP Client
        |
        v
Authentication
        |
        v
Authorization
        |
        v
Rate Limit / Replay Protection
        |
        v
DEXTR Commander
        |
        v
OS account / filesystem / process model
```

Every boundary must be explicit. Network reachability is not authorization.

## Execution authority

`execute_command` executes with the privileges of the service process. Running the service as root therefore turns command execution into root-level host control.

DEXTR Commander is **not**:
- a sandbox;
- a VM;
- a privilege-separation mechanism;
- an authorization system by itself;
- a safe public Internet shell.

## Secret handling

Do not commit:
- access tokens;
- private keys;
- tunnel credentials;
- production environment files;
- host-specific credentials;
- session or authorization state.

Run:

```bash
bash scripts/security-audit.sh
```

before publication and release.

## Remote exposure requirements

Before exposing Streamable HTTP beyond a trusted local boundary, the deployment must provide:
1. authenticated clients;
2. explicit authorization;
3. single-use authorization codes where codes are used;
4. rate limiting;
5. replay protection;
6. command execution policy;
7. file-access policy;
8. request and security-event auditing.

These controls belong in the deployment security architecture and must be verified independently.

## Incident response

If a secret is suspected to have entered Git:
1. revoke/rotate the affected credential immediately;
2. determine whether the credential was reachable in repository history;
3. remove the secret from reachable history where appropriate;
4. inspect forks, caches, releases, and other copies;
5. record the incident and remediation.

Removing a string from the current tree does not invalidate a credential or erase historical exposure by itself.
