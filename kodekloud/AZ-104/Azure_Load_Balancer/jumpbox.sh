#!/bin/bash
#
# Script to configure and manage a jumpbox server and provision webservers.
# Provides a secure gateway for accessing other servers in the network.
#
# Usage: jumpbox.sh [options]

set -e

# Ensure packages on jumpbox
sudo apt-get update -y
sudo apt-get install -y sshpass

# Define colors for web pages
colors=(red green blue)

# Loop over 2 webservers
for i in {0..1}
do
    j=$((i + 4))
    ip="10.0.2.$j"

    sshpass -p 'AzureCloudPa$$wd' \
    ssh -o StrictHostKeyChecking=no kk-root@$ip bash -c "'
        set -e
        export DEBIAN_FRONTEND=noninteractive
        export VAR=$i
        printenv | grep VAR
        echo \"Setting up webserver-0$i VM\"

        # Refresh package index to avoid 404s
        sudo apt-get update -y --fix-missing

        # Install Apache
        sudo apt-get install -y apache2

        # Ensure web root exists
        sudo mkdir -p /var/www/html

        # Set correct permissions (after Apache is installed)
        sudo chmod -R 755 /var/www/

        # Download sample HTML
        sudo curl -fsSL \
          https://raw.githubusercontent.com/Iamrushabhshahh/Linux-Scripts/main/kodekloud/AZ-104/Azure_Load_Balancer/sample.html \
          -o /var/www/html/index.html

        # Replace color placeholder
        sudo sed -i \"s/PAGECOLOR/${colors[$i]}/g\" /var/www/html/index.html

        # Restart Apache
        sudo systemctl restart apache2
        sudo systemctl enable apache2
    '"
done
