#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
TARGET="${2:-}"

[ -n "${VERSION}" ] || { echo "Использование: $0 <версия> [target]" >&2; exit 2; }
[ -n "${TARGET}" ] || TARGET="$(rustc -vV | awk '/host:/ {print $2}')"

case "${TARGET}" in
  x86_64-unknown-linux-gnu|aarch64-unknown-linux-gnu) ;;
  *) echo "Неподдерживаемая цель сборки: ${TARGET}" >&2; exit 2 ;;
esac

cargo build --release --target "${TARGET}" --bin dextr-commander --bin dextr-http

NAME="dextr-commander-${VERSION}-${TARGET}"
ROOT="dist/${NAME}"
rm -rf "${ROOT}"
mkdir -p "${ROOT}/bin" "${ROOT}/systemd"

cp "target/${TARGET}/release/dextr-commander" "${ROOT}/bin/"
cp "target/${TARGET}/release/dextr-http" "${ROOT}/bin/"
cp systemd/dextr-http.service "${ROOT}/systemd/"
cp install.sh uninstall.sh LICENSE README.md "${ROOT}/"

tar -C dist -czf "dist/${NAME}.tar.gz" "${NAME}"
sha256sum "dist/${NAME}.tar.gz" > "dist/${NAME}.tar.gz.sha256"

echo "Релиз подготовлен:"
echo "  dist/${NAME}.tar.gz"
echo "  dist/${NAME}.tar.gz.sha256"
