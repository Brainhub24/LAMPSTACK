# LAMPSTACK

![LAMP Stack Installer](https://img.shields.io/badge/LAMP-Stack-blue.svg) ![License](https://img.shields.io/github/license/brainhub24/LAMPSTACK) ![Version](https://img.shields.io/badge/version-1.3.0-green.svg) ![About](https://img.shields.io/badge/Status-Unstable-red)

A professional installer script for deploying LAMP, LAPP, and LEMP stacks on RedHat-based distributions like Rocky Linux, CentOS, and others. This script simplifies the installation of a robust stack, allowing you to choose between Apache or Nginx for your web server, and between MariaDB or PostgreSQL for your database. Additionally, it configures PHP, SSL for secure connections, and essential development tools, making it a comprehensive solution for your development needs.

I built this script specifically for my Proxmox environments, ensuring a seamless deployment process.

## Overview

The `LAMPSTACK` script automates the installation and configuration of the following components:

- **Web Server**: Apache (LAMP) or Nginx (LEMP) based on user preference
- **Database Server**: MariaDB (LAMP/LAPP) or PostgreSQL (LAPP/LEMP) based on user preference
- **PHP**: For dynamic websites and applications
- **SSL Configuration**: Automatic SSL setup via Let's Encrypt (optional)
- **Development Tools**: Essential tools like Git, GCC, and Make for development environments
- **Monitoring Tools**: Netdata for real-time system monitoring and performance insights
- **Security Tools**: Fail2Ban to protect against brute-force attacks on SSH and web services
- **Docker**: Optional installation for running containerized applications

This script makes it easy to deploy a professional LAMP stack on a Rocky Linux container running in Proxmox or similar environments.

## Features

- Simple and flexible: Install a fully-configured LAMP stack in minutes.
- Choice of web and database servers.
- SSL configuration using Let's Encrypt for HTTPS.
- Automated firewall configuration for HTTP/HTTPS services.
- Killswitch feature for complete deinstallation of all installed components.
- Includes essential monitoring (Netdata) and security (Fail2Ban) tools.

## How It Works

1. **System Update**: Updates and upgrades the system to ensure stability.
2. **Web Server Installation**: Option to install Apache or Nginx.
3. **Database Server Installation**: Option to install MariaDB or PostgreSQL.
4. **PHP Installation**: Optional PHP installation for dynamic content.
5. **SSL Configuration**: Optional SSL setup with Let's Encrypt.
6. **Monitoring & Security**: Installs Netdata for system monitoring and Fail2Ban for security.
7. **Docker**: Optional Docker installation for containerized environments.
8. **Killswitch**: Completely remove all installed components if needed.

## Usage

### Clone the Repository

```bash
git clone https://github.com/brainhub24/LAMPSTACK.git
cd LAMPSTACK
```

Run the Installer
Make sure you're running the script as root:
```bash
sudo bash 0x42.sh
```

The script will guide you through various options such as:

Selecting the web server (Apache or Nginx)
Choosing the database server (MariaDB or PostgreSQL)
Deciding whether to install PHP
Configuring SSL for secure HTTPS traffic
Installing optional tools like Docker
Killswitch (Deinstallation)
The script also includes a Killswitch feature. If you want to remove all the installed components, use the following command:
```bash
sudo bash 0x42.sh --killswitch
```

⚠️ Warning:
The Killswitch will permanently remove all installed services and data.
The process includes user confirmation, and a 30-second countdown can be canceled.

Requirements
A RedHat-based Linux distribution (Rocky Linux, CentOS, etc.)
Root or sudo access to the server
Internet connection for package downloads
Example Output
Once the installation is complete, you'll see the following access information:
```bash
ACCESS INFORMATION
-------------------------------------------------------------------------------
Your web server is accessible via the following URLs:
 - HTTP:  http://<your-ip>/
 - HTTPS (if SSL was configured): https://<your-ip>/
Netdata (monitoring) is available at:
 - http://<your-ip>:19999

For security and monitoring purposes, SSH access is available at the server's IP.
Make sure to configure SSH keys and use Fail2ban for protection.
-------------------------------------------------------------------------------
```

Disclaimer
This script is provided as-is without any guarantees or warranty.
Use it at your own risk. I am not responsible for any damage or data loss caused by using this script.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Author
Created by Jan Gebser (Brainhub24)
