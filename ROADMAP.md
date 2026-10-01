# DEXTR Commander — Public Project Roadmap

This roadmap defines the work required to present DEXTR Commander as a credible, auditable open-source MCP host-control project.

## 1. Public project identity
- [x] Establish a concise product description.
- [ ] Add project badges for build, security checks, license, Rust, MCP, and release.
- [ ] Add a concise “Why DEXTR Commander” section.
- [ ] Add a clear “What DEXTR Commander is not” section.
- [ ] Add a short real-world demo.

## 2. Developer onboarding
- [ ] Rewrite the README around a 60-second quick start.
- [ ] Document prerequisites and supported runtime assumptions.
- [ ] Document stdio and Streamable HTTP usage with runnable examples.
- [ ] Add troubleshooting guidance.
- [ ] Document development and validation commands.

## 3. Architecture and MCP integration
- [ ] Document the trust boundary and execution path.
- [ ] Document MCP tools, transports, request lifecycle, and error behavior.
- [ ] Document the recommended authenticated gateway architecture.
- [ ] Provide integration examples for MCP clients.
- [ ] Keep the host executor independent from gateway-specific infrastructure.

## 4. Security hardening
- [x] Keep secrets and deployment state outside Git.
- [x] Provide a repository secret audit script.
- [ ] Complete authentication and authorization for remote HTTP exposure.
- [ ] Make authorization codes single-use.
- [ ] Add rate limiting.
- [ ] Restrict arbitrary shell execution or replace it with an explicit command policy.
- [ ] Define and enforce file-access authorization.
- [ ] Add replay protection and request auditing.
- [ ] Document the threat model and security invariants.
- [ ] Add automated dependency and static security checks.

## 5. CI and reproducibility
- [ ] Add CI for format, check, test, clippy, release build, and security audit.
- [ ] Keep CI reproducible and independent of production infrastructure.
- [ ] Publish validation results with releases.
- [ ] Evaluate artifact provenance/attestation for release artifacts.

## 6. Community and governance
- [x] Add contribution guidance.
- [ ] Add Code of Conduct.
- [ ] Add support/troubleshooting entry point.
- [ ] Define issue and pull-request expectations.
- [ ] Add issue templates where useful.
- [ ] Add a security disclosure path that does not require public issue disclosure.

## 7. Release discipline
- [ ] Establish semantic versioning and release notes.
- [ ] Publish a first polished public release.
- [ ] Maintain CHANGELOG.md.
- [ ] Record security-impacting changes explicitly.
- [ ] Publish reproducible release/build instructions.

## 8. Visitor-facing quality bar
A new visitor should be able to answer, without reading the source:
1. What is DEXTR Commander?
2. Why would I use it?
3. How do I run it locally?
4. How do I connect an MCP client?
5. What authority does it have over the host?
6. What security controls are required before remote exposure?
7. How can I verify the implementation?
8. How can I contribute?

## Target public architecture

```text
                         MCP Client
                             |
                             v
                    DEXTR Gateway
                             |
             Authentication / Authorization
                             |
               Rate Limit / Replay Protection
                             |
                             v
                    DEXTR Commander
                         /       \
                        v         v
               execute_command  read_file
                        \         /
                         v       v
                            wmw
```

The gateway is a security boundary. DEXTR Commander itself is not a sandbox and must not be described as one.

## Execution order

### Phase P0 — Public foundation
README, roadmap, architecture, MCP guide, deployment guide, security/threat model, community files.

### Phase P1 — Verification
CI, security scanning, dependency checks, release validation, reproducible examples.

### Phase P2 — Remote security
Authentication, authorization, single-use authorization codes, rate limiting, replay protection, command/file authorization.

### Phase P3 — Release
CHANGELOG, tagged release, release notes, artifact integrity/provenance, polished examples.

### Phase P4 — Ecosystem
Integrator guides, examples, issue templates, operational runbooks, compatibility matrix.

## Current priority

The immediate priority is P0. Remote exposure hardening in P2 remains a prerequisite for describing the HTTP deployment as suitable for untrusted networks.
