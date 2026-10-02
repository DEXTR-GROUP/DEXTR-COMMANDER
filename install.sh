#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
CONFIG_DIR="${CONFIG_DIR:-/etc/dextr}"
STATE_DIR="${STATE_DIR:-/var/lib/dextr}"
LOG_DIR="${LOG_DIR:-/var/log/dextr}"
SERVICE_USER="${SERVICE_USER:-dextr}"
SERVICE_NAME="dextr-http.service"
BINARY_NAME="dextr-http"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Ошибка: установщик необходимо запускать с правами администратора." >&2
  exit 1
fi

for command in install systemctl id; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "Ошибка: не найдена необходимая команда: $command" >&2
    exit 1
  }
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BINARY="$SCRIPT_DIR/target/release/$BINARY_NAME"
SERVICE_FILE="$SCRIPT_DIR/systemd/$SERVICE_NAME"

if [[ ! -x "$BINARY" ]]; then
  echo "Ошибка: отсутствует готовая программа: $BINARY" >&2
  echo "Для установки из исходников сначала выполните: cargo build --release --bin dextr-http" >&2
  exit 1
fi

if [[ ! -f "$SERVICE_FILE" ]]; then
  echo "Ошибка: отсутствует файл службы: $SERVICE_FILE" >&2
  exit 1
fi

if ! id "$SERVICE_USER" >/dev/null 2>&1; then
  useradd --system --home-dir "$STATE_DIR" --no-create-home --shell /usr/sbin/nologin "$SERVICE_USER"
fi

install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0750 "$CONFIG_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0750 "$STATE_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_USER" -m 0750 "$LOG_DIR"

install -o root -g root -m 0755 "$BINARY" "$PREFIX/bin/$BINARY_NAME"
install -o root -g root -m 0644 "$SERVICE_FILE" "/etc/systemd/system/$SERVICE_NAME"

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

sleep 1

if ! systemctl is-active --quiet "$SERVICE_NAME"; then
  echo "Ошибка: DEXTR Commander не запустился." >&2
  systemctl status "$SERVICE_NAME" --no-pager >&2 || true
  journalctl -u "$SERVICE_NAME" --no-pager -n 50 >&2 || true
  exit 1
fi

echo
echo "DEXTR Commander установлен."
echo "Служба:       active"
echo "Автозапуск:   enabled"
echo "Пользователь: $SERVICE_USER"
echo "Программа:    $PREFIX/bin/$BINARY_NAME"
echo "Конфигурация: $CONFIG_DIR"
echo "Состояние:    $STATE_DIR"
echo "Журнал:       $LOG_DIR"
echo
echo "Для проверки:"
echo "  systemctl status $SERVICE_NAME --no-pager"
echo "  journalctl -u $SERVICE_NAME --no-pager -n 50"
