#!/bin/bash

# Run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
ZABBIX_SERVER_IP="192.168.112.120"
CLIENT_HOSTNAME=$(hostname)

# Install Zabbix repository
echo "Installing Zabbix repository..."
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest+ubuntu22.04_all.deb
apt update

# Install Zabbix agent
echo "Installing Zabbix agent..."
apt install -y zabbix-agent

# Configure Zabbix agent
echo "Configuring Zabbix agent..."
sed -i "s|Server=127.0.0.1|Server=${ZABBIX_SERVER_IP}|" /etc/zabbix/zabbix_agentd.conf
sed -i "s|ServerActive=127.0.0.1|ServerActive=${ZABBIX_SERVER_IP}|" /etc/zabbix/zabbix_agentd.conf
sed -i "s|Hostname=Zabbix server|Hostname=${CLIENT_HOSTNAME}|" /etc/zabbix/zabbix_agentd.conf

# Restart and enable Zabbix agent
echo "Starting and enabling Zabbix agent..."
systemctl restart zabbix-agent
systemctl enable zabbix-agent

# Allow Zabbix port in the firewall
echo "Allowing Zabbix port in the firewall..."
ufw allow 10050/tcp
ufw reload

echo "Zabbix agent installation and configuration complete."
