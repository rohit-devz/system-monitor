#!/bin/bash

# System Monitor - Systemd Service Uninstall Script

echo "🗑️  System Monitor Service Uninstallation"
echo "=========================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

SERVICE_NAME="system-monitor"
SERVICE_FILE="/etc/systemd/system/system-monitor.service"

echo "⚠️  This will remove the system-monitor service"
read -p "Are you sure? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
fi

# Stop the service
echo "⛔ Stopping service..."
systemctl stop "$SERVICE_NAME" 2>/dev/null || true

# Disable the service
echo "🚫 Disabling service..."
systemctl disable "$SERVICE_NAME" 2>/dev/null || true

# Remove service file
if [ -f "$SERVICE_FILE" ]; then
    echo "🗑️  Removing service file..."
    rm "$SERVICE_FILE"
fi

# Reload systemd daemon
echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

echo ""
echo "✅ Service uninstalled successfully!"
echo ""
echo "ℹ️  Project files are still at: /home/rohit/Desktop/system_monitor"
