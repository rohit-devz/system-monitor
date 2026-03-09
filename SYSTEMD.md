# Systemd Service Setup

This project includes systemd service files to run the System Monitor app as a background service on Linux.

## Files Included

- **system-monitor.service** - Systemd service configuration file
- **install-service.sh** - Installation script (run as root)
- **uninstall-service.sh** - Uninstallation script (run as root)

## Quick Installation

### Automated Installation (Recommended)

```bash
sudo bash /home/rohit/Desktop/system_monitor/install-service.sh
```

This script will:
- Copy the service file to `/etc/systemd/system/`
- Install Python dependencies
- Enable the service to start on boot
- Start the service immediately

### Manual Installation

```bash
# Copy service file
sudo cp /home/rohit/Desktop/system_monitor/system-monitor.service /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable system-monitor

# Start the service
sudo systemctl start system-monitor
```

## Service Commands

### Start Service
```bash
sudo systemctl start system-monitor
```

### Stop Service
```bash
sudo systemctl stop system-monitor
```

### Restart Service
```bash
sudo systemctl restart system-monitor
```

### Check Status
```bash
sudo systemctl status system-monitor
```

### View Live Logs
```bash
sudo journalctl -u system-monitor -f
```

### View Last 50 Log Lines
```bash
sudo journalctl -u system-monitor -n 50
```

### Disable Service (won't start on boot)
```bash
sudo systemctl disable system-monitor
```

### Re-enable Service
```bash
sudo systemctl enable system-monitor
```

## Service Configuration

### Service File Details

**Location:** `/etc/systemd/system/system-monitor.service`

Key settings:
- **Port:** 8501 (accessible at http://localhost:8501)
- **Address:** 0.0.0.0 (accessible from any network interface)
- **User:** rohit
- **Restart Policy:** Restarts on failure (max 3 restarts per 60 seconds)
- **Working Directory:** /home/rohit/Desktop/system_monitor

### Customizing the Service

To modify service settings:

```bash
sudo systemctl edit system-monitor
```

This opens an editor where you can override settings. Common changes:

**Change Port:**
```ini
[Service]
ExecStart=
ExecStart=/usr/bin/python3 -m streamlit run app.py \
    --server.port=9000 \
    --server.address=0.0.0.0
```

**Change User:**
```ini
[Service]
User=your_username
```

After editing, reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart system-monitor
```

## Uninstallation

### Automated Uninstallation

```bash
sudo bash /home/rohit/Desktop/system_monitor/uninstall-service.sh
```

### Manual Uninstallation

```bash
# Stop the service
sudo systemctl stop system-monitor

# Disable the service
sudo systemctl disable system-monitor

# Remove service file
sudo rm /etc/systemd/system/system-monitor.service

# Reload systemd
sudo systemctl daemon-reload
```

## Troubleshooting

### Service won't start

Check the status:
```bash
sudo systemctl status system-monitor
```

View detailed logs:
```bash
sudo journalctl -u system-monitor -n 100
```

### Port 8501 already in use

Find and kill the process:
```bash
lsof -i :8501
kill -9 <PID>
```

Then restart the service:
```bash
sudo systemctl restart system-monitor
```

### Permission denied errors

Ensure the user has read/write permissions:
```bash
sudo chown -R rohit:rohit /home/rohit/Desktop/system_monitor
```

### Docker socket permission denied

The service needs access to Docker socket:
```bash
# Add user to docker group
sudo usermod -aG docker rohit

# Log out and log back in, or run:
newgrp docker
```

### Service keeps restarting

Check restart limits in service file:
```bash
sudo journalctl -u system-monitor --no-pager | tail -20
```

## Security Features

The service file includes security hardening:

- **NoNewPrivileges=true** - Prevents privilege escalation
- **PrivateTmp=true** - Isolated /tmp directory
- **ProtectSystem=strict** - Read-only file system
- **ProtectHome=true** - Home directory protection
- **LimitNOFILE=65535** - File descriptor limits
- **LimitNPROC=512** - Process limits

## Enable on Boot

The service is automatically enabled on boot after installation:

```bash
# Check if enabled
sudo systemctl is-enabled system-monitor

# Output: enabled
```

The app will automatically start when the system boots.

## Monitoring

### Check if service is running
```bash
sudo systemctl is-active system-monitor
```

### Watch for errors
```bash
sudo journalctl -u system-monitor -f --since "5 minutes ago"
```

### Check resource usage
```bash
ps aux | grep streamlit
```

## Example: Auto-Restart on Failure

The service is configured to:
- Restart immediately after failure
- Max 3 restarts per 60 seconds
- Wait 10 seconds between restart attempts

This ensures the app stays running even if it crashes.

## Integration with Monitoring Tools

You can monitor the service with tools like Prometheus, Nagios, etc.:

```bash
# Check service health
sudo systemctl is-active system-monitor && echo "Running" || echo "Stopped"

# Get service status in JSON
systemctl show system-monitor --output=json
```
