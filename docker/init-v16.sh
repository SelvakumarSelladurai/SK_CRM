#!/bin/bash

set -e

echo "========================================="
echo "   Frappe CRM - Frappe v16 Setup"
echo "========================================="

# Check whether bench already exists

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Frappe bench already exists."
    echo "Starting existing bench..."

    cd /home/frappe/frappe-bench

    bench use crm.localhost

    exec bench start
fi

# Create Frappe v16 Bench

echo ""
echo "Creating Frappe v16 bench..."

bench init \
    --skip-redis-config-generation \
    --frappe-branch version-16 \
    frappe-bench


cd /home/frappe/frappe-bench

# Configure MariaDB

echo ""
echo "Configuring MariaDB..."

bench set-mariadb-host mariadb

# Configure Redis

echo ""
echo "Configuring Redis..."

bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

# Remove Redis and Watch from Procfile

echo ""
echo "Updating Procfile..."

sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

# Get Frappe CRM from GitHub

echo ""
echo "Getting Frappe CRM from GitHub..."

bench get-app https://github.com/frappe/crm.git --branch main

# Create CRM Site

echo ""
echo "Creating CRM site..."

bench new-site crm.localhost \
    --force \
    --mariadb-root-password 123 \
    --admin-password admin \
    --no-mariadb-socket

# Install CRM

echo ""
echo "Installing Frappe CRM..."

bench --site crm.localhost install-app crm

# Enable Developer Mode

echo ""
echo "Enabling developer mode..."

bench --site crm.localhost set-config developer_mode 1

# Disable outgoing emails for local development

echo ""
echo "Muting emails..."

bench --site crm.localhost set-config mute_emails 1

# Enable Server Scripts

echo ""
echo "Enabling Server Scripts..."

bench --site crm.localhost set-config server_script_enabled 1

# Clear Cache

echo ""
echo "Clearing cache..."

bench --site crm.localhost clear-cache


# --------------------------------------------------
# Select CRM Site
# --------------------------------------------------

echo ""
echo "Selecting CRM site..."

bench use crm.localhost

# Start Frappe

echo ""
echo "========================================="
echo "   Frappe CRM v16 is ready!"
echo "========================================="
echo ""
echo "URL: http://localhost:8085"
echo "CRM: http://localhost:8085/crm"
echo "Username: Administrator"
echo "Password: admin"
echo ""
echo "Starting Bench..."
echo ""

exec bench start