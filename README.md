# Router
VyOS additional Features GUI/Installation Scripts

This repository contains a script to automate the installation of ZenArmor, Pi-hole, Headscale, and VyManager on a VyOS-based system.

## Installation

To install the services, run the following command as root:

```bash
./install_all.sh
```

## Manual Configuration

### ZenArmor Registration

After running the main installation script, you will need to manually register your ZenArmor node with the ZenArmor Cloud. To do this, run the following command and follow the on-screen instructions:

```bash
sudo zenarmorctl cloud register
```

### Headscale

After the installation is complete, you will need to configure Headscale by editing the `/etc/headscale/config.yaml` file. You will need to set the `server_url` to the public IP address of this machine. After you have edited the file, restart the Headscale service with the following command:

```bash
sudo systemctl restart headscale
```

### VyManager

You can access the VyManager web interface at `http://<your_vyos_ip>:3000`.
