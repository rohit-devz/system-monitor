import streamlit as st
import psutil
import platform
import subprocess
import docker
from docker.errors import DockerException
import os
from datetime import datetime, timedelta

st.set_page_config(page_title="System Monitor", layout="wide", initial_sidebar_state="expanded")

# Custom CSS for styling
st.markdown("""
<style>
.metric-box {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 20px;
    border-radius: 10px;
    color: white;
    margin: 10px 0;
}
.system-info {
    background-color: #f0f2f6;
    padding: 20px;
    border-radius: 10px;
    margin: 10px 0;
}
.container-healthy {
    background-color: #d4edda;
    padding: 10px;
    border-radius: 5px;
    border-left: 4px solid #28a745;
    color: #155724;
}
.container-unhealthy {
    background-color: #f8d7da;
    padding: 10px;
    border-radius: 5px;
    border-left: 4px solid #dc3545;
    color: #721c24;
}
</style>
""", unsafe_allow_html=True)

def get_system_info():
    """Gather system information"""
    try:
        # OS Information
        os_name = platform.system()
        os_release = platform.release()
        os_version = platform.version()

        # Host and kernel
        hostname = platform.node()
        kernel = platform.release()

        # Uptime
        boot_time = datetime.fromtimestamp(psutil.boot_time())
        uptime = datetime.now() - boot_time

        # CPU
        cpu_count = psutil.cpu_count(logical=False)
        cpu_count_logical = psutil.cpu_count(logical=True)
        cpu_freq = psutil.cpu_freq()
        cpu_percent = psutil.cpu_percent(interval=1)

        # Memory
        memory = psutil.virtual_memory()

        # Shell
        shell = os.environ.get('SHELL', 'Unknown')

        # Disk
        disk = psutil.disk_usage('/')

        return {
            'os': os_name,
            'os_release': os_release,
            'hostname': hostname,
            'kernel': kernel,
            'uptime': uptime,
            'cpu_count': cpu_count,
            'cpu_count_logical': cpu_count_logical,
            'cpu_freq': cpu_freq,
            'cpu_percent': cpu_percent,
            'memory': memory,
            'shell': shell,
            'disk': disk
        }
    except Exception as e:
        st.error(f"Error gathering system info: {e}")
        return None

def get_docker_info():
    """Gather Docker information"""
    try:
        client = docker.from_env()

        # Get images
        images = client.images.list()

        # Get containers
        containers = client.containers.list(all=True)

        return {
            'client': client,
            'images': images,
            'containers': containers
        }
    except DockerException as e:
        return {'error': str(e)}
    except Exception as e:
        return {'error': str(e)}

def format_uptime(uptime):
    """Format uptime in readable format"""
    days = uptime.days
    hours, remainder = divmod(uptime.seconds, 3600)
    minutes = remainder // 60
    return f"{days} days, {hours} hours, {minutes} mins"

def get_docker_image_size(size_bytes):
    """Convert bytes to human readable format"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.2f} TB"

# Main app
st.title("🖥️ System Monitor")

# Refresh button
col1, col2 = st.columns([1, 4])
with col1:
    if st.button("🔄 Refresh", use_container_width=True):
        st.rerun()

# System Information Section
st.header("📊 System Information")

system_info = get_system_info()

if system_info:
    col1, col2 = st.columns(2)

    with col1:
        st.subheader("Overview")
        st.markdown(f"""
        **Hostname:** {system_info['hostname']}
        **OS:** {system_info['os']} {system_info['os_release']}
        **Kernel:** {system_info['kernel']}
        **Shell:** {system_info['shell']}
        **Uptime:** {format_uptime(system_info['uptime'])}
        """)

    with col2:
        st.subheader("Resources")
        # CPU
        st.metric("CPU Usage", f"{system_info['cpu_percent']}%",
                 f"{system_info['cpu_count']} cores ({system_info['cpu_count_logical']} logical)")

        # Memory
        mem_percent = (system_info['memory'].used / system_info['memory'].total) * 100
        st.metric("Memory",
                 f"{mem_percent:.1f}%",
                 f"{get_docker_image_size(system_info['memory'].used)} / {get_docker_image_size(system_info['memory'].total)}")

        # Disk
        disk_percent = system_info['disk'].percent
        st.metric("Disk",
                 f"{disk_percent}%",
                 f"{get_docker_image_size(system_info['disk'].used)} / {get_docker_image_size(system_info['disk'].total)}")

    # Detailed metrics
    st.subheader("Detailed Metrics")
    col1, col2, col3, col4 = st.columns(4)

    with col1:
        st.metric("CPU Frequency", f"{system_info['cpu_freq'].current:.2f} GHz")
    with col2:
        st.metric("CPU Cores", f"{system_info['cpu_count']}")
    with col3:
        st.metric("Memory Total", get_docker_image_size(system_info['memory'].total))
    with col4:
        st.metric("Disk Total", get_docker_image_size(system_info['disk'].total))

# Docker Section
st.header("🐳 Docker Information")

docker_info = get_docker_info()

if 'error' in docker_info:
    st.error(f"⚠️ Docker Error: {docker_info['error']}")
else:
    # Docker Images
    st.subheader("Docker Images")
    images = docker_info['images']

    if images:
        image_data = []
        for image in images:
            tags = image.tags if image.tags else ['<untagged>']
            image_data.append({
                'Tags': ', '.join(tags),
                'Size': get_docker_image_size(image.attrs['Size']),
                'ID': image.id[:12]
            })

        st.dataframe(image_data, use_container_width=True)
        st.metric("Total Images", len(images))
    else:
        st.info("No Docker images found")

    # Docker Containers
    st.subheader("Docker Containers")
    containers = docker_info['containers']

    if containers:
        for container in containers:
            status = container.status
            is_running = status == 'running'

            # Container health
            health_status = "Unknown"
            if 'State' in container.attrs and 'Health' in container.attrs['State']:
                health = container.attrs['State']['Health'].get('Status', 'Unknown')
                health_status = health.capitalize()

            # Display container info
            container_name = container.name
            container_image = container.image.tags[0] if container.image.tags else container.image.id[:12]

            # Color code based on status
            if is_running and health_status == "Healthy":
                css_class = "container-healthy"
                status_icon = "✅"
            else:
                css_class = "container-unhealthy"
                status_icon = "⚠️"

            col1, col2, col3 = st.columns([2, 2, 1])

            with col1:
                st.markdown(f"""
                <div class="{css_class}">
                <b>{status_icon} {container_name}</b><br>
                Image: {container_image}<br>
                ID: {container.id[:12]}
                </div>
                """, unsafe_allow_html=True)

            with col2:
                st.markdown(f"""
                <div class="{css_class}">
                <b>Status:</b> {status.upper()}<br>
                <b>Health:</b> {health_status}<br>
                <b>Created:</b> {container.attrs['Created'][:10]}
                </div>
                """, unsafe_allow_html=True)

            with col3:
                if is_running:
                    st.success(status.upper())
                else:
                    st.error(status.upper())

        st.metric("Total Containers", len(containers),
                 f"{sum(1 for c in containers if c.status == 'running')} running")
    else:
        st.info("No Docker containers found")

# Footer
st.divider()
st.caption(f"Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
