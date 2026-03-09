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

# Get the owner of the project directory (to determine which user to run as)
PROJECT_USER=$(ls -ld "$PROJECT_DIR" | awk '{print $3}')

# Check if service file exists in project
if [ ! -f "$PROJECT_DIR/system-monitor.service" ]; then
    echo "❌ Service file not found at $PROJECT_DIR/system-monitor.service"
    exit 1
fi

# Create temporary service file with correct paths and user
echo "📋 Preparing service file..."
TEMP_SERVICE=$(mktemp)
sed -e "s|/home/rohit/Desktop/system_monitor|$PROJECT_DIR|g" \
    -e "s|^User=.*|User=$PROJECT_USER|" \
    "$PROJECT_DIR/system-monitor.service" > "$TEMP_SERVICE"

# Copy service file to systemd directory
cp "$TEMP_SERVICE" "$SERVICE_FILE"
chmod 644 "$SERVICE_FILE"
rm "$TEMP_SERVICE"

# Install dependencies if not already installed
echo "📦 Installing/Verifying dependencies..."
if ! python3 -m pip list | grep -q streamlit; then
    echo "   Installing streamlit..."
    python3 -m pip install streamlit psutil docker
else
    echo "   Dependencies already installed"
fi

# Reload systemd daemon
echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

# Enable the service
echo "✅ Enabling service..."
systemctl enable "$SERVICE_NAME"

# Start the service
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
echo "📝 Useful Commands:"
echo "   Start:   sudo systemctl start $SERVICE_NAME"
echo "   Stop:    sudo systemctl stop $SERVICE_NAME"
echo "   Restart: sudo systemctl restart $SERVICE_NAME"
echo "   Status:  sudo systemctl status $SERVICE_NAME"
echo "   Logs:    sudo journalctl -u $SERVICE_NAME -f"
echo "   Disable: sudo systemctl disable $SERVICE_NAME"
echo ""
echo "✅ Service is now running!"
