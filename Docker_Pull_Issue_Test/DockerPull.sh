#!/bin/bash

# This script automates Docker Pull Issue check
# Author : Rushabh Shah
# E-mail : rushabh@kodekloud.com

echo "===================================="
echo "         Docker Pull Test           " 
echo "         -Iamrushabhshahh-          "
echo "===================================="

#######################################
# Print the message in given color.
# Arguments:
#   Color. eg: red,green
#   Message to print
#######################################

print_color () {
    case $1 in
        "green") COLOR="\033[92m";; 
        "red") COLOR="\033[31m";;
        *) COLOR="\033[0m";; # default color
    esac
    echo -e "${COLOR}$2\033[0m"
}

#######################################
# Pull and run image
# Arguments:
#   Image name. eg: nginx, redis
#######################################

pull_image () {
    kubectl run $1 --image=$1 --restart=Never &
    sleep 10
    kubectl get pod -l run=$1
}

# Check all K8s info 
print_color "red" "K8s All Info"

echo " " 
echo " " 

kubectl get all 

# Check if containerd service exists
systemctl status containerd.service > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_color "green" "Containerd Service is Running"
else
    print_color "red" "Containerd Service is Not Running | Not Exist | Not Installed"
fi

# Check hosts file
echo " " 
echo " " 
echo " " 

grep "10.0.0.6 docker-registry-mirror.kodekloud.com" /etc/hosts > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_color "green" "Hosts File Entry Exists"
else
    print_color "red" "Hosts File Entry Does Not Exist"
fi

# Check config file for CRE
echo " " 
echo " " 
echo " " 

grep "docker-registry-mirror.kodekloud.com" /etc/containerd/config.toml > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_color "green" "Config File Entry Exists at /etc/containerd/config.toml"
    pull_image nginx 
else
    print_color "red" "Config File Entry Does Not Exist in /etc/containerd/config.toml. Checking in /var/lib/rancher/k3s/agent/etc/containerd/certs.d"
    echo " "
    echo " "   
    ls -l /var/lib/rancher/k3s/agent/etc/containerd/certs.d
    echo " "
    pull_image nginx
fi
