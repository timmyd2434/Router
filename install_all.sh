#!/bin/bash

# This script automates the installation of ZenArmor, Pi-hole, Headscale, and VyManager.
# It is intended to be run on a Debian-based system like VyOS.

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# --- Install Docker and Docker Compose ---
echo "--- Installing Docker and Docker Compose ---"
if ! command -v docker &> /dev/null
then
    echo "Docker not found, installing..."
    apt-get update
    apt-get install -y docker.io
fi
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose not found, installing..."
    apt-get install -y docker-compose
fi
echo "--- Docker and Docker Compose Installation Complete ---"
echo ""

# --- ZenArmor ---
echo "--- Starting ZenArmor Installation ---"
echo "WARNING: The ZenArmor installation is interactive and cannot be fully automated."
echo "You will be prompted to answer a few questions during the installation."
if ! command -v zenarmorctl &> /dev/null
then
    echo "ZenArmor not found, installing..."
    if [ ! -f /tmp/zenarmor_install.sh ]; then
        curl -o /tmp/zenarmor_install.sh https://updates.zenarmor.com/getzenarmor
    fi
    chmod +x /tmp/zenarmor_install.sh
    /tmp/zenarmor_install.sh
fi
echo "--- ZenArmor Installation Complete ---"
echo "Please see README.md for instructions on how to register your ZenArmor node."
echo ""

# --- Pi-hole ---
echo "--- Starting Pi-hole Installation ---"
if ! command -v pihole &> /dev/null
then
    echo "Pi-hole not found, installing..."
    mkdir -p /etc/pihole
    PIHOLE_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
    cat > /etc/pihole/setupVars.conf << EOL
PIHOLE_INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
PIHOLE_DNS_1=8.8.8.8
PIHOLE_DNS_2=8.8.4.4
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
WEBPASSWORD=$PIHOLE_PASSWORD
EOL
    if [ ! -f /tmp/pihole_install.sh ]; then
        curl -sSL -o /tmp/pihole_install.sh https://install.pi-hole.net
    fi
    chmod +x /tmp/pihole_install.sh
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    /tmp/pihole_install.sh --unattended
    echo "Your Pi-hole password is: $PIHOLE_PASSWORD"
fi
echo "--- Pi-hole Installation Complete ---"
echo ""

# --- Headscale ---
echo "--- Starting Headscale Installation ---"
if ! command -v headscale &> /dev/null
then
    echo "Headscale not found, installing..."
    HEADSCALE_VERSION="0.27.1"
    HEADSCALE_ARCH=$(dpkg --print-architecture)
    wget --output-document=/tmp/headscale.deb \
     "https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${HEADSCALE_ARCH}.deb"
    apt install -y /tmp/headscale.deb
    mkdir -p /etc/headscale
    curl -o /etc/headscale/config.yaml https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml
    systemctl enable --now headscale
    echo "--- Headscale Installation Complete ---"
    echo "Please configure Headscale by editing /etc/headscale/config.yaml and restarting the service."
    echo "You will need to set the 'server_url' to the public IP address of this machine."
fi
echo ""

# --- VyManager ---
echo "--- Starting VyManager Installation ---"
if [ ! -d "/opt/VyManager" ]; then
    echo "VyManager not found, installing..."
    git clone https://github.com/Community-VyProjects/VyManager/ /opt/VyManager
    cd /opt/VyManager
    docker-compose up -d
    echo "--- VyManager Installation Complete ---"
    echo "You can access the VyManager web interface at http://<your_vyos_ip>:3000"
fi

echo "--- Installation Script Finished ---"
