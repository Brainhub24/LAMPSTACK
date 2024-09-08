#!/bin/bash
#===============================================================================#
# TITLE:        Linux Professional Stack Installer (REDHAT-Based)               #
# DESCRIPTION:  This script installs a professional simple lamp stack.          #
#                                                                               #
# VERSION:      1.3.0                                                           #
# AUTHOR:       Jan Gebser (Brainhub24)                                         #
# Github:       https://brainhub24.com                                          #
# Repo  :       https://us24.net/0x42                                           #
#                                                                               #
# COPYRIGHT:    Copyright (c) 2024, NETCORE.DIGITAL                             #
# LICENSE:      MIT License                                                     #
# DISCLAIMER:   Use this script at your own risk.                               #
#               I am not responsible for any damage or data loss caused by      #
#               using my script. It is not the final version!                   #
#===============================================================================#

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Function to standardize user input for yes/no questions
confirm_yes() {
  case "$1" in
    [Yy]*|[1]*|[Yy]es|[Yy]eah) return 0 ;;
    *) return 1 ;;
  esac
}

confirm_no() {
  case "$1" in
    [Nn]*|[0]*|[Nn]o|[Nn]ö) return 0 ;;
    *) return 1 ;;
  esac
}

# Function for 30-second countdown
countdown() {
  secs=30
  echo "Countdown to Killswitch: Press any key to cancel..."
  while [ $secs -gt 0 ]; do
    printf "Removing in %02d seconds. \r" $secs
    read -t 1 -n 1 key
    if [ $? -eq 0 ]; then
      echo -e "\nKillswitch cancelled."
      exit 0
    fi
    ((secs--))
  done
  echo -e "\nProceeding with Killswitch..."
}

#-------------------------------------------------------------------------------
# KILLSWITCH: DEINSTALLATION OF COMPONENTS
# If the -ks or --killswitch flag is passed, uninstall all components.
#-------------------------------------------------------------------------------
if [[ "$1" == "-ks" || "$1" == "--killswitch" ]]; then
  echo "-------------------------------------------------------------------------------"
  echo "WARNING: You are about to activate the Killswitch!"
  echo "This will permanently remove all installed components, and no data can be recovered."
  echo "Do you accept this disclaimer and wish to proceed? (yes/no)"
  echo "Valid inputs: Yes, yes, yeah, y, 1 or No, no, nö, n, 0."
  echo "-------------------------------------------------------------------------------"

  read -p "Enter your response: " killswitch_accept
  if confirm_no "$killswitch_accept"; then
    echo "Killswitch aborted by user."
    exit 0
  elif ! confirm_yes "$killswitch_accept"; then
    echo "Invalid input. Killswitch aborted."
    exit 1
  fi

  echo "-------------------------------------------------------------------------------"
  echo "FINAL WARNING: This process will permanently delete all installed services and data!"
  echo "No data can be recovered after this operation."
  echo "To confirm you understand, type the following sentence exactly:"
  echo "\"I understand all data will be deleted and cannot be recovered.\""
  echo "-------------------------------------------------------------------------------"

  read -p "Type the sentence here: " confirmation_sentence

  if [ "$confirmation_sentence" != "I understand all data will be deleted and cannot be recovered." ]; then
    echo "The sentence was not entered correctly. Killswitch aborted."
    exit 1
  fi

  echo "-------------------------------------------------------------------------------"
  echo "You have confirmed the permanent deletion of all services and data."
  countdown

  # Perform Killswitch Deinstallation
  echo "Starting Killswitch deinstallation..."

  echo "Stopping and removing web server..."
  if systemctl is-active --quiet httpd; then
    systemctl stop httpd
    systemctl disable httpd
    dnf remove httpd -y
    echo "Apache removed."
  elif systemctl is-active --quiet nginx; then
    systemctl stop nginx
    systemctl disable nginx
    dnf remove nginx -y
    echo "Nginx removed."
  else
    echo "No web server found to remove."
  fi

  echo "Stopping and removing database server..."
  if systemctl is-active --quiet mariadb; then
    systemctl stop mariadb
    systemctl disable mariadb
    dnf remove mariadb-server -y
    echo "MariaDB removed."
  elif systemctl is-active --quiet postgresql; then
    systemctl stop postgresql
    systemctl disable postgresql
    dnf remove postgresql postgresql-server -y
    echo "PostgreSQL removed."
  else
    echo "No database server found to remove."
  fi

  echo "Removing PHP (if installed)..."
  dnf remove php php-mysqlnd php-fpm php-json php-cli -y

  echo "Removing Docker (if installed)..."
  dnf remove docker-ce docker-ce-cli containerd.io -y
  systemctl stop docker
  systemctl disable docker

  echo "Removing Netdata (if installed)..."
  systemctl stop netdata
  systemctl disable netdata
  dnf remove netdata -y

  echo "Removing Fail2ban (if installed)..."
  systemctl stop fail2ban
  systemctl disable fail2ban
  dnf remove fail2ban -y

  echo "Resetting firewall rules for HTTP and HTTPS..."
  firewall-cmd --permanent --remove-service=http
  firewall-cmd --permanent --remove-service=https
  firewall-cmd --reload

  echo "-------------------------------------------------------------------------------"
  echo "All installed components have been successfully removed."
  echo "The Killswitch process is complete. Your system is now clean."
  echo "-------------------------------------------------------------------------------"

  exit 0
fi

#-------------------------------------------------------------------------------
# 1. SYSTEM UPDATE AND UPGRADE
# Update all packages to the latest version to ensure a stable base system.
#-------------------------------------------------------------------------------
echo "Updating system..."
dnf update -y
dnf upgrade -y

#-------------------------------------------------------------------------------
# 2. INSTALL DEVELOPMENT TOOLS
# Install essential development tools like GCC, Make, Git.
#-------------------------------------------------------------------------------
echo "Installing development tools..."
dnf groupinstall "Development Tools" -y
dnf install git -y

#-------------------------------------------------------------------------------
# 3. INSTALL WEB SERVER (CHOOSE APACHE OR NGINX)
# Option to install either Apache or Nginx based on user preference.
#-------------------------------------------------------------------------------
echo "Installing web server..."
read -p "Do you want to install Apache or Nginx? (apache/nginx): " webserver

if [ "$webserver" == "apache" ]; then
  dnf install httpd -y
  systemctl start httpd
  systemctl enable httpd
  echo "Apache installed and running."
elif [ "$webserver" == "nginx" ]; then
  dnf install nginx -y
  systemctl start nginx
  systemctl enable nginx
  echo "Nginx installed and running."
else
  echo "Invalid input. Exiting..."
  exit 1
fi

#-------------------------------------------------------------------------------
# 4. INSTALL DATABASE (CHOOSE MARIADB OR POSTGRESQL)
# Option to install either MariaDB or PostgreSQL based on user preference.
#-------------------------------------------------------------------------------
echo "Installing database server..."
read -p "Do you want to install MariaDB or PostgreSQL? (mariadb/postgresql): " db

if [ "$db" == "mariadb" ]; then
  dnf install mariadb-server -y
  systemctl start mariadb
  systemctl enable mariadb
  mysql_secure_installation
  echo "MariaDB installed and running."
elif [ "$db" == "postgresql" ]; then
  dnf install postgresql postgresql-server -y
  postgresql-setup --initdb
  systemctl start postgresql
  systemctl enable postgresql
  echo "PostgreSQL installed and running."
else
  echo "Invalid input. Exiting..."
  exit 1
fi

#-------------------------------------------------------------------------------
# 5. INSTALL PHP (OPTIONAL) OR OTHER LANGUAGE RUNTIME ENVIRONMENTS
# Install PHP if you're running dynamic websites, or Python/Node.js for other use cases.
#-------------------------------------------------------------------------------
read -p "Do you want to install PHP? (yes/no): " php
if confirm_yes "$php"; then
  echo "Installing PHP..."
  dnf install php php-mysqlnd php-fpm php-json php-cli -y
  systemctl restart httpd 2>/dev/null || systemctl restart nginx
  echo "PHP installed."
else
  echo "Skipping PHP installation."
fi

#-------------------------------------------------------------------------------
# 6. CONFIGURE FIREWALL
# Open necessary ports for web traffic (HTTP and HTTPS).
#-------------------------------------------------------------------------------
echo "Configuring firewall..."
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
echo "Firewall configured."

#-------------------------------------------------------------------------------
# 7. INSTALL SSL (LET'S ENCRYPT) FOR HTTPS
# Install and configure SSL certificates using Let's Encrypt for secure HTTPS.
#-------------------------------------------------------------------------------
read -p "Do you want to configure SSL using Let's Encrypt? (yes/no): " ssl
if confirm_yes "$ssl"; then
  echo "Installing Let's Encrypt SSL..."
  if [ "$webserver" == "apache" ]; then
    dnf install certbot python3-certbot-apache -y
    certbot --apache
  elif [ "$webserver" == "nginx" ]; then
    dnf install certbot python3-certbot-nginx -y
    certbot --nginx
  fi
  echo "SSL configured."
else
  echo "Skipping SSL configuration."
fi

#-------------------------------------------------------------------------------
# 8. INSTALL MONITORING TOOLS (NETDATA)
# Monitor your system performance using Netdata.
#-------------------------------------------------------------------------------
echo "Installing Netdata for system monitoring..."
dnf install netdata -y
systemctl start netdata
systemctl enable netdata
echo "Netdata installed and running on port 19999."

#-------------------------------------------------------------------------------
# 9. INSTALL FAIL2BAN FOR SECURITY
# Protect the system from brute-force attacks with Fail2ban.
#-------------------------------------------------------------------------------
echo "Installing Fail2ban for SSH protection..."
dnf install fail2ban -y
systemctl start fail2ban
systemctl enable fail2ban
echo "Fail2ban installed and running."

#-------------------------------------------------------------------------------
# 10. OPTIONAL: INSTALL DOCKER FOR CONTAINERIZED APPLICATIONS
# Install Docker if you plan to run microservices or containers.
#-------------------------------------------------------------------------------
read -p "Do you want to install Docker? (yes/no): " docker
if confirm_yes "$docker"; then
  echo "Installing Docker..."
  dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  dnf install docker-ce docker-ce-cli containerd.io -y
  systemctl start docker
  systemctl enable docker
  echo "Docker installed."
else
  echo "Skipping Docker installation."
fi

#-------------------------------------------------------------------------------
# 11. DISPLAY SYSTEM ACCESS INFORMATION
# This section retrieves the system's IP address and provides URLs for accessing
# the web server and monitoring tools.
#-------------------------------------------------------------------------------
IP=$(hostname -I | awk '{print $1}')  # Fetch the first IP address
echo " "
echo "-------------------------------------------------------------------------------"
echo "ACCESS INFORMATION"
echo "-------------------------------------------------------------------------------"
echo "Your web server is accessible via the following URLs:"
echo " - HTTP:  http://$IP/"
echo " - HTTPS (if SSL was configured): https://$IP/"
echo "Netdata (monitoring) is available at:"
echo " - http://$IP:19999"
echo " "
echo "For security and monitoring purposes, SSH access is available at the server's IP."
echo "Make sure to configure SSH keys and use Fail2ban for protection."
echo "-------------------------------------------------------------------------------"

#-------------------------------------------------------------------------------
# CONCLUSION
#-------------------------------------------------------------------------------
echo "Installation complete! Your professional lamp stack is up and running."
echo "You now have a web server, database, firewall, SSL (if configured), and monitoring tools in place."
echo "For further configuration, visit the official documentation of each component."

#-------------------------------------------------------------------------------
# DISCLAIMER
#-------------------------------------------------------------------------------
echo "DISCLAIMER: This script is provided as-is without any guarantees or warranty.
Use it at your own risk. The author is not responsible for any damage or data loss."
