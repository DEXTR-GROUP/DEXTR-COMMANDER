#!/usr/bin/env bash
set -euo pipefail

PREFIX="/usr/local/bin"
CONFIG_DIR="/etc/dextr"
STATE_DIR="/var/lib/dextr"
LOG_DIR="/var/log/dextr"
SERVICE_USER="dextr"
SERVICE_GROUP="dextr"
SERVICE_NAME="dextr-http.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Использование: sudo ./scripts/install.sh [каталог с готовыми бинарниками]"
  echo "По умолчанию используется target/release."
  exit 0
fi

[[ "$EUID" -eq 0 ]] || { echo "Ошибка: запустите установщик с правами root." >&2; exit 1; }
[[ "$(uname -s)" == "Linux" ]] || { echo "Ошибка: установщик предназначен для Linux." >&2; exit 1; }

SOURCE_DIR="${1:-target/release}"
for binary in dextr-commander dextr-http; do
  [[ -f "$SOURCE_DIR/$binary" ]] || { echo "Ошибка: не найден $SOURCE_DIR/$binary" >&2; exit 1; }
  chmod +x "$SOURCE_DIR/$binary"
done

getent group "$SERVICE_GROUP" >/dev/null 2>&1 || groupadd --system "$SERVICE_GROUP"
id "$SERVICE_USER" >/dev/null 2>&1 || useradd --system --gid "$SERVICE_GROUP" --home-dir "$STATE_DIR" --no-create-home --shell /usr/sbin/nologin "$SERVICE_USER"

install -d -o root -g "$SERVICE_GROUP" -m 0750 "$CONFIG_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_GROUP" -m 0750 "$STATE_DIR"
install -d -o "$SERVICE_USER" -g "$SERVICE_GROUP" -m 0750 "$LOG_DIR"

install -m 0755 "$SOURCE_DIR/dextr-commander" "$PREFIX/dextr-commander"
install -m 0755 "$SOURCE_DIR/dextr-http" "$PREFIX/dextr-http"

if [[ ! -f "$SERVICE_FILE" ]]; then
  cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=DEXTR Commander MCP Streamable HTTP server
Documentation=https://github.com/DEXTR-GROUP/DEXTR-COMMANDER
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=dextr
Group=dextr
ExecStart=/usr/local/bin/dextr-http
Restart=on-failure
RestartSec=2
StartLimitIntervalSec=60
StartLimitBurst=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictSUIDSGID=true
LockPersonality=true
RestrictRealtime=true
RestrictNamespaces=true

[Install]
WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

if ! systemctl is-active --quiet "$SERVICE_NAME"; then
  echo "Ошибка: DEXTR Commander не запустился." >&2
  systemctl status "$SERVICE_NAME" --no-pager || true
  journalctl -u "$SERVICE_NAME" --no-pager -n 50 || true
  exit 1
fi

echo
echo "DEXTR Commander установлен."
echo "Служба: активна"
echo "Автозапуск: включён"
echo "Пользователь: $SERVICE_USER"
echo "MCP: http://127.0.0.1:8787/mcp"
