# Deployment Guide

## Local Development

### Run Locally
```bash
streamlit run app.py
```

The app will be available at `http://localhost:8501`

---

## Production Deployment

### 1. **Streamlit Cloud** (Recommended - Easiest)

```bash
# Push to GitHub first
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/system-monitor.git
git push -u origin main
```

Then:
1. Go to [streamlit.io/cloud](https://streamlit.io/cloud)
2. Click "New app"
3. Select your GitHub repository
4. Choose the `app.py` file
5. Click "Deploy"

---

### 2. **Docker Deployment**

#### Create Dockerfile
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Expose Streamlit port
EXPOSE 8501

# Run Streamlit
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

#### Build and Run Docker Image
```bash
# Build
docker build -t system-monitor .

# Run
docker run -p 8501:8501 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  system-monitor
```

#### Docker Compose
```yaml
version: '3.8'

services:
  system-monitor:
    build: .
    ports:
      - "8501:8501"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - STREAMLIT_SERVER_HEADLESS=true
```

Run:
```bash
docker-compose up
```

---

### 3. **Systemd Service** (Linux)

#### Create Service File
```bash
sudo nano /etc/systemd/system/system-monitor.service
```

```ini
[Unit]
Description=System Monitor Streamlit App
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/home/rohit/Desktop/system_monitor
ExecStart=/usr/bin/python3 -m streamlit run app.py --server.port=8501 --server.address=0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

#### Enable and Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable system-monitor
sudo systemctl start system-monitor

# Check status
sudo systemctl status system-monitor

# View logs
sudo journalctl -u system-monitor -f
```

---

### 4. **Heroku Deployment**

#### Create Procfile
```
web: streamlit run app.py --server.port=$PORT --server.address=0.0.0.0
```

#### Create runtime.txt
```
python-3.11.0
```

#### Deploy
```bash
# Install Heroku CLI
# Then:
heroku login
heroku create YOUR_APP_NAME
git push heroku main

# View logs
heroku logs --tail
```

---

### 5. **AWS EC2 Deployment**

```bash
# Connect to EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Update system
sudo yum update -y

# Install Python and pip
sudo yum install python3 python3-pip -y

# Install Docker
sudo yum install docker -y
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Clone your repository
git clone https://github.com/YOUR_USERNAME/system-monitor.git
cd system-monitor

# Install dependencies
pip3 install -r requirements.txt

# Run app
streamlit run app.py --server.port=8501 --server.address=0.0.0.0
```

Access at: `http://your-instance-ip:8501`

---

### 6. **DigitalOcean App Platform**

1. Push code to GitHub
2. Go to [DigitalOcean App Platform](https://cloud.digitalocean.com/apps)
3. Click "Create App"
4. Select your GitHub repository
5. Set build command: `pip install -r requirements.txt`
6. Set run command: `streamlit run app.py --server.port=8080 --server.address=0.0.0.0`
7. Deploy

---

### 7. **Azure App Service**

```bash
# Login to Azure
az login

# Create resource group
az group create --name system-monitor-rg --location eastus

# Create App Service plan
az appservice plan create \
  --name system-monitor-plan \
  --resource-group system-monitor-rg \
  --sku B1 \
  --is-linux

# Create web app
az webapp create \
  --resource-group system-monitor-rg \
  --plan system-monitor-plan \
  --name system-monitor-app \
  --runtime "PYTHON:3.11"

# Deploy code
az webapp deployment source config-zip \
  --resource-group system-monitor-rg \
  --name system-monitor-app \
  --src app.zip
```

---

### 8. **Google Cloud Run**

```bash
# Create Dockerfile (see Docker section above)

# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/system-monitor

# Deploy to Cloud Run
gcloud run deploy system-monitor \
  --image gcr.io/YOUR_PROJECT_ID/system-monitor \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8501
```

---

## Environment Variables

Create `.env` file for sensitive configs:

```bash
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_ADDRESS=0.0.0.0
STREAMLIT_SERVER_HEADLESS=true
STREAMLIT_LOGGER_LEVEL=warning
```

Load with:
```bash
export $(cat .env | xargs)
streamlit run app.py
```

---

## Monitoring & Logs

### Check if app is running
```bash
curl http://localhost:8501
```

### Monitor with htop
```bash
htop
```

### Enable SSL/HTTPS (with Nginx)
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8501;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

---

## Quick Commands Reference

| Command | Purpose |
|---------|---------|
| `streamlit run app.py` | Run locally |
| `docker build -t system-monitor .` | Build Docker image |
| `docker run -p 8501:8501 system-monitor` | Run Docker container |
| `docker-compose up` | Run with compose |
| `systemctl start system-monitor` | Start systemd service |
| `git push heroku main` | Deploy to Heroku |

---

## Troubleshooting

### Port already in use
```bash
lsof -i :8501
kill -9 <PID>
```

### Docker permission denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Module not found
```bash
pip install -r requirements.txt
```

### Docker daemon not running
```bash
sudo systemctl start docker
```
