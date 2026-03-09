# System Monitor App

A Streamlit-based system monitor application that displays system information (similar to neofetch) and Docker container/image statistics.

## Features

### System Information
- OS and Kernel details
- Hostname and Shell
- System Uptime
- CPU Usage and Frequency
- Memory Usage
- Disk Usage
- CPU cores (physical and logical)

### Docker Information
- Docker Images list with sizes
- Running and stopped containers
- Container health status
- Container details (name, image, ID, status)
- Total running containers count

## Installation

### Prerequisites
- Python 3.8+
- Docker (for Docker features)

### Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the app:
```bash
streamlit run app.py
```

The app will open in your default browser at `http://localhost:8501`

## Usage

- **Refresh Button**: Click the 🔄 Refresh button to update all metrics
- **Auto-refresh**: Streamlit will update the app automatically when you make changes to the code

## Docker Access

Make sure your user has permission to access Docker:

```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and log back in or run:
newgrp docker
```

## Dependencies

- **streamlit**: Web UI framework
- **psutil**: System and process utilities
- **docker**: Docker SDK for Python

## Notes

- The app displays real-time system metrics
- Docker information is pulled directly from the Docker daemon
- Container health status depends on Docker healthcheck configuration
- All metrics are refreshed on demand via the Refresh button
