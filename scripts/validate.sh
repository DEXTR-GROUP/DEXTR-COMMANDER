#!/usr/bin/env bash
set -euo pipefail

echo "== DEXTR Commander validation =="

cargo fmt --check
cargo check
cargo test
cargo clippy --all-targets --all-features -- -D warnings
cargo build --release
bash scripts/security-audit.sh

echo "== VALIDATION PASS =="
