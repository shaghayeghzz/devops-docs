#!/bin/bash

# Install Nginx
echo "Installing Nginx..."
sudo apt update
sudo apt install -y nginx




# Unlink default configuration
echo "Unlinking the default Nginx configuration..."
sudo unlink /etc/nginx/sites-enabled/default



# Create ha.conf configuration
echo "Creating ha.conf configuration file..."
sudo bash -c 'cat > /etc/nginx/sites-available/ha.conf' <<EOF
server {
    listen 5000;

    root /var/www/html;
    index index.html;

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "Healthy";
        add_header Content-Type text/plain;
    }

    # Default location
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF




# Enable ha.conf configuration
echo "Enabling ha.conf configuration..."
sudo ln -s /etc/nginx/sites-available/ha.conf /etc/nginx/sites-enabled/ha.conf



# Create a simple HTML file
echo "Creating a simple HTML file..."
echo "<h1>Welcome to Nginx Server on $(hostname)</h1>" | sudo tee /var/www/html/index.html




# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx




# Check Nginx status
echo "Nginx status:"
sudo systemctl status nginx --no-pager



echo "Script execution completed! Visit your server IP address in a browser to view the page."

