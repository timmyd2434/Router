#!/bin/bash

# This script automates the installation of the router services.
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

# --- Create directories ---
echo "--- Creating directories ---"
mkdir -p ./etc-pihole
mkdir -p ./etc-dnsmasq.d
mkdir -p ./headscale/config
mkdir -p ./headscale/data
echo "--- Directory creation complete ---"
echo ""

# --- Create Headscale config ---
echo "--- Creating Headscale config ---"
curl -o ./headscale/config/config.yaml https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml
echo "--- Headscale config created ---"
echo ""

# --- Generate Pi-hole password ---
echo "--- Generating Pi-hole password ---"
export PIHOLE_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
echo "Your Pi-hole password is: $PIHOLE_PASSWORD"
echo "--- Pi-hole password generated ---"
echo ""

# --- Start services ---
echo "--- Starting services ---"
docker-compose up -d
echo "--- Services started ---"
echo ""

echo "--- Installation Script Finished ---"
