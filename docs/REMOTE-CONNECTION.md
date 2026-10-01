# Remote Connection

This document describes how to connect an MCP client to a remotely deployed DEXTR Commander.

## Architecture

```text
MCP Client
    |
    | MCP / HTTPS
    v
DEXTR Gateway or authenticated HTTP boundary
    |
    | private network / Tailscale
    v
wmw
    |
    v
DEXTR Commander
    |
    +--> execute_command
    +--> read_file
```

## Connection models

### Local stdio

```text
MCP Client -> stdin/stdout -> dextr-commander
```

### Private Tailscale connection

```text
MCP Client -> Tailscale -> wmw / DEXTR Commander
```

The client connects to the documented Tailscale hostname and MCP path exposed by the deployment. Device enrollment is performed outside the repository.

### Authenticated gateway

```text
MCP Client -> HTTPS -> Authenticated DEXTR Gateway
                                      |
                                      v
                              private network
                                      |
                                      v
                              DEXTR Commander
```

The gateway is responsible for authentication, authorization, rate limiting, replay protection, and forwarding only authorized MCP traffic.

## First connection

A deployment should publish:
- canonical MCP endpoint;
- transport;
- network path;
- authentication method;
- authorization flow.

Example:

```text
MCP endpoint: https://HOSTNAME/mcp
Transport: Streamable HTTP
Network: Tailscale or authenticated HTTPS
```

Replace HOSTNAME with the actual documented endpoint.

## Verify connectivity

```bash
curl -i https://HOSTNAME/mcp
```

A successful network connection does not imply authorization.

## Security requirements

Before remote use, verify authentication, authorization, single-use authorization codes, rate limiting, replay protection, command policy, file-access policy, least privilege, and security auditing.

## Tailscale notes

Tailscale provides network reachability and identity at the network layer. It does not by itself define which MCP tools a client may invoke.

Never place Tailscale auth keys, API keys, ACL secrets, or node credentials in this repository.
