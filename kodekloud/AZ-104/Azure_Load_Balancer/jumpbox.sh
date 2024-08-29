#!/bin/bash
#
# This script is used to configure and manage a jumpbox server.
# It provides a secure gateway for accessing other servers in the network.
# The script is designed to be run on a Linux machine.
#
# Usage: jumpbox.sh [options]

sudo apt update -y

sudo apt install sshpass -y

colors=(red green blue)

for i in {0..1}
do
    j=$(($i + 4))
    ip="10.0.2.$j"
    sshpass -p 'C0ntr0lplan3Pa$$wd' \
    ssh -o StrictHostKeyChecking=no kk-root@$ip bash -c  \
    "'export VAR=$i
printenv | grep VAR
echo "Setting up webserver-0$i VM"
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
sudo curl "https://raw.githubusercontent.com/Iamrushabhshahh/Linux-Scripts/main/kodekloud/AZ-104/Azure_Load_Balancer/sample.html" > /var/www/html/index.html
sed -i "s/PAGECOLOR/${colors[$i]}/g" /var/www/html/index.html
exit
    '"
done