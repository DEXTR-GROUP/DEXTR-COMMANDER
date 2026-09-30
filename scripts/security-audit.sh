#!/usr/bin/env bash
set -euo pipefail

# DEXTR Commander repository secret audit.
# Scans every blob reachable from all Git refs, not only the current checkout.

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
fail=0
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

patterns=(
  'BEGIN[[:space:]]+(RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY'
  'ghp_[A-Za-z0-9_]{20,}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'glpat-[A-Za-z0-9_-]{20,}'
  'xox[baprs]-[A-Za-z0-9-]{20,}'
  'AKIA[0-9A-Z]{16}'
  'ASIA[0-9A-Z]{16}'
  'AWS_SECRET_ACCESS_KEY[[:space:]]*='
  'OPENAI_API_KEY[[:space:]]*='
  'ANTHROPIC_API_KEY[[:space:]]*='
  'TAILSCALE_AUTH_KEY[[:space:]]*='
  'CF_API_TOKEN[[:space:]]*='
  'CLIENT_SECRET[[:space:]]*='
  'PASSWORD[[:space:]]*='
  'SECRET_KEY[[:space:]]*='
  'API_KEY[[:space:]]*='
  'AUTH_TOKEN[[:space:]]*='
  'Authorization:[[:space:]]*Bearer[[:space:]]+[A-Za-z0-9._~+/=-]{20,}'
)

echo "[1/3] Scanning reachable Git blobs..."
while read -r object path; do
  [ -n "$object" ] || continue
  [ "$(git cat-file -t "$object")" = "blob" ] || continue
  git cat-file blob "$object" >"$tmp"
  for pattern in "${patterns[@]}"; do
    if grep -aEniE "$pattern" "$tmp" >/dev/null 2>&1; then
      echo "POTENTIAL SECRET: blob=$object path=$path pattern=$pattern"
      grep -aEniE "$pattern" "$tmp" | head -n 3 | sed -E 's/([A-Za-z0-9+\/_=-]{8})[A-Za-z0-9+\/_=-]{12,}/\1[REDACTED]/g'
      fail=1
    fi
  done
done < <(git rev-list --objects --all)

echo "[2/3] Checking tracked paths for sensitive filenames..."
sensitive_paths="$(git ls-files | grep -Ei '(^|/)(\.env($|\.)|.*\.(pem|key|p12|pfx|jks|keystore|ovpn|kubeconfig|tfstate)(\.|$)|id_(rsa|ed25519)(\.|$)|credentials?($|\.)|secrets?($|\.))' || true)"
if [ -n "$sensitive_paths" ]; then
  echo "$sensitive_paths"
  fail=1
else
  echo "No sensitive tracked filenames found."
fi

echo "[3/3] Checking repository refs..."
git show-ref --head >/dev/null

if [ "$fail" -ne 0 ]; then
  echo "SECRET AUDIT: FAIL"
  exit 1
fi
echo "SECRET AUDIT: PASS"
