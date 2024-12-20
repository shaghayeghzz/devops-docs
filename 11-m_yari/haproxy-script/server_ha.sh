#!/bin/bash

# Install HAProxy
echo "Installing HAProxy..."
sudo apt update
sudo apt install -y haproxy



# Backup existing HAProxy configuration
echo "Backing up the existing HAProxy configuration..."
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak



# Apply new HAProxy configuration
echo "Applying new HAProxy configuration..."
sudo bash -c 'cat > /etc/haproxy/haproxy.cfg' <<EOF
#---------------------------------------------------------------------
# Default settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 2048
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000ms
    timeout client  50000ms
    timeout server  50000ms

#---------------------------------------------------------------------
# Frontend configuration
#---------------------------------------------------------------------
frontend http_front
    bind *:80
    default_backend nginx_backend
    option httpchk GET /health
    http-request add-header X-Forwarded-For %[src]

#---------------------------------------------------------------------
# Backend configuration with health checks
#---------------------------------------------------------------------
backend nginx_backend
    balance roundrobin
    option httpchk GET /health
    server nginx1 192.168.91.138:5000 check
    server nginx2 192.168.91.139:80 check

#---------------------------------------------------------------------
# HAProxy stats page
#---------------------------------------------------------------------
frontend stats
    bind *:8080
    stats enable
    stats uri /stats
    stats refresh 10s
    stats auth admin:admin
EOF

# Restart HAProxy
echo "Restarting HAProxy to apply changes..."
sudo systemctl restart haproxy

# Enable HAProxy to start on boot
echo "Enabling HAProxy to start on boot..."
sudo systemctl enable haproxy

# Check HAProxy status
echo "HAProxy status:"
sudo systemctl status haproxy --no-pager

echo "HAProxy setup is complete. Access:"
