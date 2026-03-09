#!/bin/bash

# System Monitor - Systemd Service Installation Script

echo "🔧 System Monitor Service Installation"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
SERVICE_NAME="system-monitor"
SERVICE_FILE="/etc/systemd/system/system-monitor.service"

# Get the owner of the project directory
PROJECT_USER=$(ls -ld "$PROJECT_DIR" | awk '{print $3}')

# Check if virtual environment exists
if [ ! -d "$PROJECT_DIR/venv" ]; then
    echo "❌ Virtual environment not found!"
    echo ""
    echo "Please run the setup first:"
    echo "   bash $PROJECT_DIR/setup-venv.sh"
    exit 1
fi

PYTHON_BIN="$PROJECT_DIR/venv/bin/python"

echo "📋 Creating service file..."

# Create service file directly
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=System Monitor - Streamlit Application
Documentation=https://streamlit.io
After=network.target docker.service
Wants=docker.service

[Service]
Type=simple
User=$PROJECT_USER
WorkingDirectory=$PROJECT_DIR
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
ExecStart=$PYTHON_BIN -m streamlit run app.py \\
    --server.port=8501 \\
    --server.address=0.0.0.0 \\
    --server.headless=true \\
    --logger.level=warning

# Restart policy
Restart=always
RestartSec=10
StartLimitInterval=60s
StartLimitBurst=3

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$PROJECT_DIR
BindPaths=/var/run/docker.sock:/var/run/docker.sock

# Resource limits
LimitNOFILE=65535
LimitNPROC=512

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=system-monitor

[Install]
WantedBy=multi-user.target
EOF

chmod 644 "$SERVICE_FILE"

echo "✅ Service file created: $SERVICE_FILE"
echo ""
echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

# Stop any existing service
systemctl stop "$SERVICE_NAME" 2>/dev/null || true

echo "✅ Enabling service..."
systemctl enable "$SERVICE_NAME"

echo "▶️  Starting service..."
systemctl start "$SERVICE_NAME"

echo ""
echo "✨ Installation complete!"
echo ""
echo "📊 Service Information:"
echo "   Service name: $SERVICE_NAME"
echo "   Service file: $SERVICE_FILE"
echo "   Project directory: $PROJECT_DIR"
echo "   Running as user: $PROJECT_USER"
echo "   Access URL: http://localhost:8501"
echo ""
echo "⏳ Waiting for service to start..."
sleep 2

echo ""
echo "📊 Service Status:"
systemctl status "$SERVICE_NAME" --no-pager

echo ""
echo "📝 Useful Commands:"
echo "   Start:   sudo systemctl start $SERVICE_NAME"
echo "   Stop:    sudo systemctl stop $SERVICE_NAME"
echo "   Restart: sudo systemctl restart $SERVICE_NAME"
echo "   Status:  sudo systemctl status $SERVICE_NAME"
echo "   Logs:    sudo journalctl -u $SERVICE_NAME -f"
echo "   Disable: sudo systemctl disable $SERVICE_NAME"
