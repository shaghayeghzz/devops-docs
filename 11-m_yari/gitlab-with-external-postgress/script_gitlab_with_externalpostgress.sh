#!/bin/bash

# Step 1: Install PostgreSQL on the external server (if not already installed)
echo "Updating package index and installing PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Step 2: Create GitLab database and user
echo "Creating PostgreSQL database and user for GitLab..."
sudo -u postgres psql <<EOF
CREATE DATABASE gitlabdb;
CREATE USER pmke WITH PASSWORD '1qaz!QAZ';
GRANT ALL PRIVILEGES ON DATABASE gitlabdb TO pmke;
\q
EOF

# Step 3: Configure PostgreSQL to accept external connections
echo "Configuring PostgreSQL to accept external connections..."

# Update listen_addresses to allow external connections
POSTGRES_VERSION=$(ls /etc/postgresql/)
POSTGRES_CONF_FILE="/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $POSTGRES_CONF_FILE

# Edit pg_hba.conf to allow GitLab server IP
PG_HBA_FILE="/etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf"
GITLAB_SERVER_IP="192.168.91.112"  # Replace with actual GitLab server IP
sudo bash -c "echo 'host    all             all             $GITLAB_SERVER_IP/32      md5' >> $PG_HBA_FILE"

# Step 4: Restart PostgreSQL to apply the changes
echo "Restarting PostgreSQL..."
sudo systemctl restart postgresql

# Step 5: Test the connection from GitLab server to PostgreSQL
echo "Testing connection from GitLab server to PostgreSQL..."
psql -h 192.168.91.112 -U pmke -d gitlabdb -c "\l"  # Replace with actual PostgreSQL server IP

echo "PostgreSQL setup for GitLab completed!"

# Step 6: Install required dependencies
echo "Installing dependencies..."
sudo apt install -y ca-certificates curl openssh-server postfix tzdata perl

# Step 7: Configure Postfix (Internet Site and domain name)
echo "Configuring Postfix..."
# You may need to manually set your domain name during the postfix installation

# Step 8: Move to /tmp directory
cd /tmp

# Step 9: Download the GitLab installation script
echo "Downloading GitLab installation script..."
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh

# Step 10: Run the installer
echo "Running GitLab installation script..."
sudo bash /tmp/script.deb.sh

# Step 11: Install GitLab Community Edition
echo "Installing GitLab CE..."
sudo apt install -y gitlab-ce

# Step 12: Adjust firewall rules
echo "Adjusting firewall rules..."
sudo ufw allow http
sudo ufw allow https
sudo ufw allow OpenSSH

echo "GitLab installation complete!"

# Step 13: Configure GitLab to use external PostgreSQL
GITLAB_CONF_FILE="/etc/gitlab/gitlab.rb"
POSTGRES_IP="192.168.91.112"  # Replace with actual PostgreSQL IP
DB_USER="pmke"
DB_PASSWORD="1qaz!QAZ"

echo "Configuring GitLab to use external PostgreSQL..."

# Disable GitLab's embedded PostgreSQL and configure external database settings
sudo sed -i "s/# postgresql['enable'] = true/postgresql['enable'] = false/" $GITLAB_CONF_FILE
sudo sed -i "s/# gitlab_rails['db_adapter'] = 'postgresql'/gitlab_rails['db_adapter'] = 'postgresql'/" $GITLAB_CONF_FILE
sudo sed -i "s/# gitlab_rails['db_encoding'] = 'unicode'/gitlab_rails['db_encoding'] = 'unicode'/" $GITLAB_CONF_FILE
sudo sed -i "s/# gitlab_rails['db_host'] = 'localhost'/gitlab_rails['db_host'] = '$POSTGRES_IP'/" $GITLAB_CONF_FILE
sudo sed -i "s/# gitlab_rails['db_port'] = 5432/gitlab_rails['db_port'] = 5432/" $GITLAB_CONF_FILE
sudo sed -i "s/# gitlab_rails['db_database'] = 'gitlabhq_production'/gitlab_rails['db_database'] = 'gitlabhq_production'/" $GITLAB_CONF_FILE
sudo sed -i "s/# gitlab_rails['db_username'] = 'gitlab_user'/gitlab_rails['db_username'] = '$DB_USER'/" $GITLAB_CONF_FILE
sudo sed -i "s/# gitlab_rails['db_password'] = 'your_secure_password'/gitlab_rails['db_password'] = '$DB_PASSWORD'/" $GITLAB_CONF_FILE

# Step 14: Reconfigure GitLab to apply the changes
echo "Reconfiguring GitLab..."
sudo gitlab-ctl reconfigure

echo "GitLab configuration to use external PostgreSQL is complete!"
