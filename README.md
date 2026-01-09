# Router
VyOS additional Features GUI/Installation Scripts

This repository contains a script to automate the installation of ZenArmor, Pi-hole, Headscale, and VyManager on a VyOS-based system using Docker.

## Installation

To install the services, run the following command as root:

```bash
./install_all.sh
```

## Manual Configuration

### Headscale

After the installation is complete, you will need to configure Headscale by editing the `./headscale/config/config.yaml` file. You will need to set the `server_url` to the public IP address of this machine. After you have edited the file, restart the Headscale service with the following command:

```bash
docker-compose restart headscale
```

### Pi-hole

Your Pi-hole password will be displayed at the end of the installation.

### VyManager

You can access the VyManager web interface at `http://<your_vyos_ip>:3000`.
