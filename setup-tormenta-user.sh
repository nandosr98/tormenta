#!/usr/bin/env bash
set -euo pipefail

# Setup OpenClaw to run under dedicated system user: tormenta
# Run this script from a terminal with sudo privileges.

echo "[1/8] Creating dedicated system user 'tormenta'..."
sudo useradd -r -m -d /home/tormenta -s /usr/sbin/nologin tormenta || true

echo "[2/8] Creating OpenClaw directories..."
sudo mkdir -p /home/tormenta/.openclaw
sudo mkdir -p /home/tormenta/.openclaw/workspace

echo "[3/8] Copying current OpenClaw state from fernando to tormenta..."
sudo rsync -a /home/fernando/.openclaw/ /home/tormenta/.openclaw/

echo "[4/8] Fixing ownership..."
sudo chown -R tormenta:tormenta /home/tormenta/.openclaw

echo "[5/8] Installing systemd service for tormenta..."
sudo tee /etc/systemd/system/openclaw-gateway.service >/dev/null <<'EOF'
[Unit]
Description=OpenClaw Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=tormenta
Group=tormenta
Environment=HOME=/home/tormenta
Environment=OPENCLAW_CONFIG_PATH=/home/tormenta/.openclaw/openclaw.json
ExecStart=/usr/bin/node /home/fernando/.npm-global/lib/node_modules/openclaw/dist/index.js gateway --port 18789
Restart=on-failure
RestartSec=3
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
ReadWritePaths=/home/tormenta/.openclaw

[Install]
WantedBy=multi-user.target
EOF

echo "[6/8] Enabling system service..."
sudo systemctl daemon-reload
sudo systemctl enable --now openclaw-gateway.service

echo "[7/8] Disabling old user-level service (fernando)..."
systemctl --user disable --now openclaw-gateway.service || true

echo "[8/8] Verifying status..."
sudo systemctl status openclaw-gateway.service --no-pager -l || true
ps -eo user,pid,cmd | grep -E "openclaw|dist/index.js gateway" | grep -v grep || true
openclaw status || true

echo "Done. OpenClaw should now run as user 'tormenta'."
