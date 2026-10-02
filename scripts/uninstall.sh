#!/usr/bin/env bash
set -euo pipefail
PREFIX="/usr/local/bin"
SERVICE_NAME="dextr-http.service"
[[ "$EUID" -eq 0 ]] || { echo "Ошибка: удаление необходимо выполнять с правами root." >&2; exit 1; }
systemctl disable --now "$SERVICE_NAME" 2>/dev/null || true
rm -f "/etc/systemd/system/$SERVICE_NAME"
systemctl daemon-reload
rm -f "$PREFIX/dextr-commander" "$PREFIX/dextr-http"
echo "DEXTR Commander и системная служба удалены."
echo "Конфигурация, состояние и журналы сохранены."
