#!/usr/bin/env bash
set -euo pipefail

PREFIX="/usr/local/bin"
CONFIG_DIR="/etc/dextr"
STATE_DIR="/var/lib/dextr"
LOG_DIR="/var/log/dextr"
SERVICE_USER="dextr"
SERVICE_GROUP="dextr"
SERVICE_NAME="dextr-http.service"

die() { echo "Ошибка: $*" >&2; exit 1; }
need_root() { [ "$(id -u)" -eq 0 ] || die "установщик должен быть запущен от root."; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || die "не найдена команда: $1"; }

need_root
need_cmd install
need_cmd systemctl
need_cmd id

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BINARY="$SCRIPT_DIR/target/release/dextr-http"
UNIT="$SCRIPT_DIR/systemd/dextr-http.service"

[ -x "$BINARY" ] || die "не найден готовый файл $BINARY. Сначала соберите релиз командой: cargo build --release --bin dextr-http"
[ -f "$UNIT" ] || die "не найден файл службы: $UNIT"

echo "Установка DEXTR Commander..."

if ! getent group "$SERVICE_GROUP" >/dev/null 2>&1; then
    groupadd --system "$SERVICE_GROUP"
fi

if ! id "$SERVICE_USER" >/dev/null 2>&1; then
    useradd --system --gid "$SERVICE_GROUP" --home-dir "$STATE_DIR" --no-create-home --shell /usr/sbin/nologin "$SERVICE_USER"
fi

install -d -o "$SERVICE_USER" -g "$SERVICE_GROUP" -m 0750 "$CONFIG_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_GROUP" -m 0750 "$STATE_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_GROUP" -m 0750 "$LOG_DIR"

install -m 0755 "$BINARY" "$PREFIX/dextr-http"
install -m 0644 "$UNIT" "/etc/systemd/system/$SERVICE_NAME"

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

echo
echo "Проверка установки..."
systemctl is-enabled --quiet "$SERVICE_NAME" || die "автозапуск службы не включён."
systemctl is-active --quiet "$SERVICE_NAME" || {
    systemctl status "$SERVICE_NAME" --no-pager || true
    die "служба DEXTR Commander не запустилась."
}

echo
echo "DEXTR Commander установлен."
echo "Служба: работает"
echo "Автозапуск: включён"
echo "MCP: http://127.0.0.1:8787/mcp"
echo
echo "Проверка:"
echo "  systemctl status $SERVICE_NAME"
echo "  journalctl -u $SERVICE_NAME --no-pager -n 50"
