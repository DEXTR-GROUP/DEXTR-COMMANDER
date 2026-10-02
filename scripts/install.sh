#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
CONFIG_DIR="${CONFIG_DIR:-/etc/dextr}"
STATE_DIR="${STATE_DIR:-/var/lib/dextr}"
LOG_DIR="${LOG_DIR:-/var/log/dextr}"
SERVICE_USER="${SERVICE_USER:-dextr}"
SERVICE_GROUP="${SERVICE_GROUP:-dextr}"

fail() { echo "ОШИБКА: $*" >&2; exit 1; }
info() { echo "[DEXTR] $*"; }

[[ "${EUID}" -eq 0 ]] || fail "установщик необходимо запускать от root."
command -v systemctl >/dev/null || fail "systemd не найден."
command -v install >/dev/null || fail "команда install не найдена."

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
BINARY="${PROJECT_ROOT}/target/release/dextr-http"
UNIT="${PROJECT_ROOT}/systemd/dextr-http.service"

[[ -x "${BINARY}" ]] || fail "не найден готовый бинарник: ${BINARY}. Сначала выполните cargo build --release."
[[ -f "${UNIT}" ]] || fail "не найден файл службы: ${UNIT}."

info "Создание системной группы: ${SERVICE_GROUP}"
if ! getent group "${SERVICE_GROUP}" >/dev/null; then
  groupadd --system "${SERVICE_GROUP}"
fi

info "Создание системного пользователя: ${SERVICE_USER}"
if ! id "${SERVICE_USER}" >/dev/null 2>&1; then
  useradd --system --gid "${SERVICE_GROUP}" --home-dir /var/lib/dextr --no-create-home --shell /usr/sbin/nologin "${SERVICE_USER}"
fi

info "Создание каталогов"
install -d -o "${SERVICE_USER}" -g "${SERVICE_GROUP}" -m 0750 "${CONFIG_DIR}"
install -d -o "${SERVICE_USER}" -g "${SERVICE_GROUP}" -m 0750 "${STATE_DIR}"
install -d -o "${SERVICE_USER}" -g "${SERVICE_GROUP}" -m 0750 "${LOG_DIR}"

info "Установка программы"
install -o root -g root -m 0755 "${BINARY}" "${PREFIX}/bin/dextr-http"

info "Установка системной службы"
install -o root -g root -m 0644 "${UNIT}" /etc/systemd/system/dextr-http.service

info "Проверка конфигурации systemd"
systemd-analyze verify /etc/systemd/system/dextr-http.service

info "Перечитывание конфигурации systemd"
systemctl daemon-reload

info "Включение автоматического запуска"
systemctl enable dextr-http.service

info "Запуск DEXTR Commander"
systemctl restart dextr-http.service

sleep 1

info "Проверка состояния"
if ! systemctl is-active --quiet dextr-http.service; then
  systemctl status dextr-http.service --no-pager || true
  journalctl -u dextr-http.service --no-pager -n 50 || true
  fail "DEXTR Commander не запустился."
fi

info "Проверка автоматического запуска"
systemctl is-enabled --quiet dextr-http.service || fail "автоматический запуск не включён."

info "Установка завершена."
echo
echo "DEXTR Commander: работает"
echo "Автозапуск:     включён"
echo "Пользователь:   ${SERVICE_USER}"
echo "Конфигурация:   ${CONFIG_DIR}"
echo "Состояние:      ${STATE_DIR}"
echo "Журналы:        ${LOG_DIR}"
echo
echo "Проверка:"
echo "  systemctl status dextr-http.service"
echo "  journalctl -u dextr-http.service"
