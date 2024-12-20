#!/bin/bash

# Set default variables for configuration
BOND_IP="192.168.91.130/24"   # Default IP address for bond0
GATEWAY_IP="192.168.91.2"     # Default gateway
DNS_SERVER="10.0.0.10"        # Default DNS server
DNS_SEARCH_DOMAIN="srvM1"     # Default DNS search domain

# Define the netplan configuration file
NETPLAN_FILE="/etc/netplan/01-bond-config.yaml"

# Write a base netplan configuration to the file
sudo bash -c "cat > $NETPLAN_FILE" <<EOL
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      dhcp6: false
    ens37:
      dhcp4: false
      dhcp6: false
    ens38:
      dhcp4: false
      dhcp6: false
  bonds:
    bond0:
      addresses: [$BOND_IP]           # Static IP for bond0
      routes:
        - to: default
          via: $GATEWAY_IP           # Default gateway
          metric: 100
      nameservers:
        addresses: [$DNS_SERVER]     # DNS server
        search: [$DNS_SEARCH_DOMAIN] # DNS search domain
      interfaces:
        - ens37                      # Add ens37 to the bond
        - ens38                      # Add ens38 to the bond
      parameters:
        mode: balance-rr             # Round-robin load balancing
        mii-monitor-interval: 100    # Link monitoring interval (100 ms)
        primary: ens33               # ens33 as the primary interface
EOL

# Open the configuration file in vim for manual editing
echo "Opening the netplan configuration file in vim for editing..."
sudo vim $NETPLAN_FILE

# Confirm and apply the configuration
read -p "Do you want to apply the configuration now? (y/n): " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
    echo "Applying netplan configuration..."
    sudo netplan apply
    echo "Configuration applied. Verifying bond interface..."
    ip addr show bond0
    cat /proc/net/bonding/bond0
else
    echo "Configuration saved but not applied."
fi
