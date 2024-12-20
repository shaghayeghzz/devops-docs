#!/bin/bash

# Set PostgreSQL version and other configurations
POSTGRES_VERSION="14"
REPLICATOR_PASSWORD="replicator_password"
MASTER_IP="192.168.112.150"  # Replace with your actual Master server IP

# Install PostgreSQL
install_postgresql() {
    echo "Installing PostgreSQL on the Master server..."
    sudo apt update
    sudo apt install -y postgresql-$POSTGRES_VERSION postgresql-client-$POSTGRES_VERSION
}

# Configure PostgreSQL Master server for replication
configure_master() {
    echo "Configuring PostgreSQL Master server..."

    # Modify PostgreSQL configuration for replication
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf.conf
    sudo sed -i "s/#wal_level = replica/wal_level = replica/g" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf.conf
    sudo sed -i "s/#max_wal_senders = 10/max_wal_senders = 10/g" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf.conf
    sudo sed -i "s/#hot_standby = off/hot_standby = on/g" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf.conf

    # Allow replication connections from the Slave server
    echo "host    replication     replicator    $MASTER_IP/32      md5" | sudo tee -a /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf

    # Restart PostgreSQL service to apply changes
    sudo systemctl restart postgresql
}

# Create replicator role for replication
create_replicator_user() {
    echo "Creating replicator user on the Master server..."
    sudo -u postgres psql -c "CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '$REPLICATOR_PASSWORD';"
}

# Run functions
install_postgresql
configure_master
create_replicator_user

echo "PostgreSQL Master configuration completed!"
