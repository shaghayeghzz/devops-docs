#!/bin/bash

# Function to check if the user is root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "You are not root. Switching to root..."
        sudo "$0" "$@"
        if [ $? -ne 0 ]; then
            echo "Failed to switch to root. Make sure you have sudo privileges."
            exit 1
        fi
        exit 0
    fi
}

# Main script starts here
check_root

# Commands to run as root
echo "You are now root."
echo "Running privileged commands..."

# Example privileged commands
#apt update && apt upgrade -y
echo "System updated successfully."

wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu22.04_all.deb
if [ $? -ne 0 ]; then
    echo "Failed to install zabbix. Please check for any errors."
    exit 1
else
    echo "Package installed successfully."
fi
dpkg -i zabbix-release_latest+ubuntu22.04_all.deb
apt update



echo "Installing Zabbix components..."
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
if [ $? -ne 0 ]; then
    echo "Failed to install Zabbix components. Please check for any errors."
    exit 1
else
    echo "Zabbix components installed successfully."
fi
# Install MySQL
echo "Installing MySQL..."
sudo apt update
sudo apt install -y mysql-server

# Start MySQL service (if not already started)
sudo systemctl start mysql

# Log into MySQL as root user and configure the database
echo "Configuring MySQL for Zabbix..."
sudo mysql -u root -e "
-- Create Zabbix database
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- Create Zabbix user and grant privileges
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '1qaz!QAZ';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';

-- Set global variable to allow function creators
SET GLOBAL log_bin_trust_function_creators = 1;
"

echo "MySQL setup for Zabbix is complete."

# Install Zabbix components
echo "Installing Zabbix components..."
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
if [ $? -ne 0 ]; then
    echo "Failed to install Zabbix components. Please check for any errors."
    exit 1
else
    echo "Zabbix components installed successfully."
fi


echo "Importing Zabbix database schema..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

echo "Zabbix database schema imported successfully."



ROOT_PASSWORD="123"

# Set global variable 'log_bin_trust_function_creators' to 0
mysql -uroot -p"$ROOT_PASSWORD" -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "MySQL global variable 'log_bin_trust_function_creators' set to 0."
else
    echo "Failed to set the global variable."
    exit 1
fi

# Exit the script
echo "MySQL global variable update complete."



DB_PASSWORD="1qaz!QAZ"

# Path to the Zabbix server configuration file
ZABBIX_CONFIG_FILE="/etc/zabbix/zabbix_server.conf"

# Check if the configuration file exists
if [ ! -f "$ZABBIX_CONFIG_FILE" ]; then
    echo "Error: $ZABBIX_CONFIG_FILE file not found."
    exit 1
fi

# Update DBPassword in the Zabbix configuration file
echo "Configuring Zabbix server database password..."

# Remove any existing DBPassword lines and add the new one
sudo sed -i "/^# DBPassword=/s/^# //" "$ZABBIX_CONFIG_FILE"  # Uncomment the line if commented
sudo sed -i "s/^DBPassword=.*/DBPassword=$DB_PASSWORD/" "$ZABBIX_CONFIG_FILE"  # Set new DBPassword

# If no DBPassword was previously set, add it
if ! grep -q "^DBPassword=" "$ZABBIX_CONFIG_FILE"; then
    echo "DBPassword=$DB_PASSWORD" | sudo tee -a "$ZABBIX_CONFIG_FILE" > /dev/null
fi

# Verify the change was successful
grep "DBPassword=" "$ZABBIX_CONFIG_FILE"
if [ $? -eq 0 ]; then
    echo "Zabbix server database password configured successfully."
else
    echo "Failed to configure Zabbix server database password."
    exit 1
fi




# Define the port and server IP for 'listen' and 'server_name'
LISTEN_PORT="8080"  # Your desired port (e.g., 80 or 8080)
SERVER_IP="192.168.112.150"  # Your server IP or any other desired IP

# Path to the Nginx configuration file for Zabbix
NGINX_CONFIG_FILE="/etc/zabbix/nginx.conf"

# Check if the configuration file exists
if [ ! -f "$NGINX_CONFIG_FILE" ]; then
    echo "Error: $NGINX_CONFIG_FILE file not found."
    exit 1
fi

# Only modify 'listen' and 'server_name'
echo "Configuring Nginx for Zabbix..."

# Change 'listen' to the specified port and uncomment it
sudo sed -i "s/^# listen .*/listen $LISTEN_PORT;/" "$NGINX_CONFIG_FILE"
sudo sed -i "s/^\(listen\s\+\)\([0-9]\+\)\(;.*\)$/\1$LISTEN_PORT\3/" "$NGINX_CONFIG_FILE"

# Change 'server_name' to your IP address
# This will ensure 'server_name' is replaced with your IP, whether commented or not
sudo sed -i "s/^#\?\s*server_name\s\+.*$/server_name $SERVER_IP;/" "$NGINX_CONFIG_FILE"

# Display the changes for verification
grep "listen" "$NGINX_CONFIG_FILE"
grep "server_name" "$NGINX_CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "Nginx configuration for Zabbix updated successfully."
else
    echo "Failed to update Nginx configuration."
    exit 1
fi

echo "Nginx configuration complete."


systemctl restart zabbix-server zabbix-agent nginx php8.1-fpm
systemctl enable zabbix-server zabbix-agent nginx php8.1-fpm