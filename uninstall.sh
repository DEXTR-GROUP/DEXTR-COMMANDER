#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="dextr-http.service"
SERVICE_USER="dextr"
SERVICE_GROUP="dextr"

[ "$(id -u)" -eq 0 ] || { echo "Ошибка: запустите с правами root." >&2; exit 1; }

systemctl disable --now "${SERVICE_NAME}" 2>/dev/null || true
rm -f "/etc/systemd/system/${SERVICE_NAME}" "/usr/local/bin/dextr-http"
systemctl daemon-reload

echo "Программа и системная служба удалены."
echo "Каталоги /etc/dextr, /var/lib/dextr и /var/log/dextr сохранены."
echo "Системный пользователь ${SERVICE_USER} и группа ${SERVICE_GROUP} сохранены для безопасного удаления данных вручную."
echo "Это позволяет не уничтожить пользовательскую конфигурацию и журналы без явного решения администратора."
