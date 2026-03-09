#!/bin/bash

# System Monitor - Systemd Service Installation Script

echo "🔧 System Monitor Service Installation"
echo "========================================"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

# Variables
SERVICE_FILE="/etc/systemd/system/system-monitor.service"
PROJECT_DIR="/home/rohit/Desktop/system_monitor"
SERVICE_NAME="system-monitor"

# Check if service file exists in project
if [ ! -f "$PROJECT_DIR/system-monitor.service" ]; then
    echo "❌ Service file not found at $PROJECT_DIR/system-monitor.service"
    exit 1
fi

# Copy service file to systemd directory
echo "📋 Copying service file..."
cp "$PROJECT_DIR/system-monitor.service" "$SERVICE_FILE"
chmod 644 "$SERVICE_FILE"

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
