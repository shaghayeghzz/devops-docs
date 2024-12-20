#!/bin/bash

# Set PostgreSQL version and other configurations
POSTGRES_VERSION="14"
REPLICATOR_PASSWORD="1qaz!QAZ"
MASTER_IP="192.168.112.150"  # Replace with your actual Master server IP
SLAVE_IP="192.168.112.151"   # Replace with your actual Slave server IP

# Install PostgreSQL
install_postgresql() {
    echo "Installing PostgreSQL on the Slave server..."
    sudo apt update
    sudo apt install -y postgresql-$POSTGRES_VERSION postgresql-client-$POSTGRES_VERSION
}

# Configure PostgreSQL Slave server for replication
configure_slave() {
    echo "Configuring PostgreSQL Slave server..."

    # Stop PostgreSQL service on the Slave server
    sudo systemctl stop postgresql

    # Remove old data from the slave
    sudo rm -rf /var/lib/postgresql/$POSTGRES_VERSION/main/*

    # Use pg_basebackup to sync data from the Master server
    sudo -u postgres pg_basebackup -h $MASTER_IP -D /var/lib/postgresql/$POSTGRES_VERSION/main -U replicator -Fp -Xs -P -R

    # Create standby.signal file to mark this as a standby server
    echo "standby_mode = 'on'" | sudo tee -a /var/lib/postgresql/$POSTGRES_VERSION/main/postgresql.auto.conf
    echo "primary_conninfo = 'host=$MASTER_IP port=5432 user=replicator password=$REPLICATOR_PASSWORD'" | sudo tee -a /var/lib/postgresql/$POSTGRES_VERSION/main/postgresql.auto.conf

    # Start PostgreSQL service on the Slave server
    sudo systemctl start postgresql
}

# Verify replication status on Slave server
verify_replication() {
    echo "Verifying replication on Slave..."

    # On Slave, check replication status
    sudo -u postgres psql -c "SELECT * FROM pg_stat_wal_receiver;"
}

# Run functions
install_postgresql
configure_slave
verify_replication

echo "PostgreSQL Slave configuration completed!"
