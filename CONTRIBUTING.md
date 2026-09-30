# Contributing to DEXTR Commander

Contributions are welcome.

## Development

Install a stable Rust toolchain and run:

```bash
cargo check
cargo build --release
```

Keep changes focused and document externally visible behavior.

Do not commit credentials, private infrastructure configuration, tunnel tokens, or host-specific state.

## Pull requests

Describe the problem, implementation, and validation performed. Changes to command execution, filesystem access, transport behavior, or authentication boundaries require explicit security consideration.
