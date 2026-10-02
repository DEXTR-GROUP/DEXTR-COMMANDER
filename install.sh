#!/usr/bin/env bash
set -euo pipefail

PREFIX="/usr/local/bin"
CONFIG_DIR="/etc/dextr"
STATE_DIR="/var/lib/dextr"
LOG_DIR="/var/log/dextr"
SERVICE_USER="dextr"
SERVICE_GROUP="dextr"
SERVICE_NAME="dextr-http.service"
BINARY="dextr-http"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_BINARY="${SOURCE_DIR}/target/release/${BINARY}"
SYSTEMD_UNIT="/etc/systemd/system/${SERVICE_NAME}"

die() { echo "Ошибка: $*" >&2; exit 1; }
info() { echo "DEXTR: $*"; }

[ "$(id -u)" -eq 0 ] || die "запустите установщик с правами root: sudo ./install.sh"
[ -x "${SOURCE_BINARY}" ] || die "не найден ${SOURCE_BINARY}. Сначала выполните cargo build --release --bin dextr-http"

command -v systemctl >/dev/null || die "systemd не найден"
command -v install >/dev/null || die "install не найден"

info "Создание системной группы"
if ! getent group "${SERVICE_GROUP}" >/dev/null; then
    groupadd --system "${SERVICE_GROUP}"
fi

info "Создание системного пользователя"
if ! id "${SERVICE_USER}" >/dev/null 2>&1; then
    useradd --system --gid "${SERVICE_GROUP}" --home-dir "${STATE_DIR}" --no-create-home --shell /usr/sbin/nologin "${SERVICE_USER}"
fi

info "Создание каталогов"
install -d -o "${SERVICE_USER}" -g "${SERVICE_GROUP}" -m 0750 "${CONFIG_DIR}"
install -d -o "${SERVICE_USER}" -g "${SERVICE_GROUP}" -m 0750 "${STATE_DIR}"
install -d -o "${SERVICE_USER}" -g "${SERVICE_GROUP}" -m 0750 "${LOG_DIR}"

info "Установка программы"
install -o root -g root -m 0755 "${SOURCE_BINARY}" "${PREFIX}/${BINARY}"

info "Установка системной службы"
install -o root -g root -m 0644 "${SOURCE_DIR}/systemd/dextr-http.service" "${SYSTEMD_UNIT}"

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"

info "Проверка службы"
systemctl is-enabled --quiet "${SERVICE_NAME}" || die "автозапуск службы не включён"
systemctl is-active --quiet "${SERVICE_NAME}" || {
    systemctl status "${SERVICE_NAME}" --no-pager || true
    die "служба не запустилась"
}

info "DEXTR Commander установлен и запущен."
echo
echo "Служба:    ${SERVICE_NAME}"
echo "Состояние: работает"
echo "Автозапуск: включён"
echo "MCP:       локальная точка согласно конфигурации"
echo
echo "Проверка:"
echo "  systemctl status ${SERVICE_NAME}"
echo "  journalctl -u ${SERVICE_NAME} --no-pager -n 50"
