#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="dextr-http.service"
SERVICE_USER="${SERVICE_USER:-dextr}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Ошибка: удаление необходимо выполнять с правами администратора." >&2
  exit 1
fi

systemctl disable --now "$SERVICE_NAME" 2>/dev/null || true
rm -f "/etc/systemd/system/$SERVICE_NAME"
rm -f "/usr/local/bin/dextr-http"
systemctl daemon-reload

echo "DEXTR Commander удалён."
echo "Пользователь $SERVICE_USER и данные не удалены автоматически."
echo "Это сделано намеренно, чтобы не удалить конфигурацию или журналы без подтверждения."
