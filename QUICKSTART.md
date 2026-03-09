# Quick Start Guide

## Installation Steps

### Step 1: Set Up Virtual Environment

The system requires Python packages to be installed in a virtual environment due to PEP 668 security restrictions.

```bash
bash setup-venv.sh
```

This will:
- Create a Python virtual environment in the `venv/` directory
- Install all required dependencies (streamlit, psutil, docker)

### Step 2: Install as Systemd Service (Optional)

To run the app as a background service on Linux:

```bash
sudo bash install-service.sh
```

This will:
- Create a systemd service file
- Enable auto-start on system boot
- Start the service immediately

## Quick Commands

### Run Locally (Without Service)

After setting up the venv:

```bash
./venv/bin/python -m streamlit run app.py
```

Or activate the venv first:

```bash
source venv/bin/activate
streamlit run app.py
```

### Manage Service

```bash
# View status
sudo systemctl status system-monitor

# Start
sudo systemctl start system-monitor

# Stop
sudo systemctl stop system-monitor

# Restart
sudo systemctl restart system-monitor

# View logs
sudo journalctl -u system-monitor -f
```

## Access the App

Once running, access at:
```
http://localhost:8501
```

## Troubleshooting

### Virtual environment won't create
```bash
# Install python3-venv if missing
sudo apt install python3-venv
```

### Permission denied when running service
```bash
# Make sure the project directory is owned by your user
sudo chown -R $USER:$USER /path/to/system-monitor
```

### Docker socket permission
```bash
# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

## File Structure

```
system-monitor/
├── app.py                    # Main Streamlit app
├── requirements.txt          # Python dependencies
├── setup-venv.sh            # Virtual environment setup
├── install-service.sh       # Systemd service installer
├── uninstall-service.sh     # Systemd service uninstaller
├── venv/                    # Virtual environment (created by setup-venv.sh)
├── README.md                # Full documentation
├── DEPLOYMENT.md            # Deployment guides
└── SYSTEMD.md              # Systemd service documentation
```
