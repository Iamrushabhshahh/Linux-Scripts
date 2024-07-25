#!/bin/bash
#
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
        "*") COLOR="\033[0m";; # default color
    esac
    echo -e "${COLOR} $2 \033[0m"
}

#######################################
# Pull and run image
# Arguments:
#   Image name. eg: nginx, redis
#######################################

pull_image() {
    echo "\n\n\n Pulling Image Running Nginx Pod\n\n\n"
    kubectl run $1 --image=$1 
    sleep 10
    kubectl get pod
}


# Check Host Entries for Docker Registry | Check this for all Enviornments
grep -Fx "10.0.0.6 docker-registry-mirror.kodekloud.com" /etc/hosts
if [ $? -eq 0 ]; then
    print_color "green" " \n Hosts File Entry Exists \n"
else
    print_color "red" "\n Hosts File Entry Does Not Exist \n"
fi

# CHECK DOCKER
which docker
if [ $? -eq 0 ]; then
    print_color "green" " \n Docker is Installed (Version: $(docker --version)) \n"
    cat /etc/docker/daemon.json | grep "docker-registry-mirror.kodekloud.com"
    print_color "green" " \n Checking For Docker Pull \n \n \n"
    docker run docker/whalesay cowsay KodeKloud #Chcecking Docker pull
else
    print_color "red" "\n Docker is Not Installed \n\n\n"

    print_color "green" "Checking For Kubernetes \n"

    kubectl get all
    echo "\n\n\n"
    systemctl status containerd.service
    if [ $? -eq 0 ]; then
        print_color "green" "Containerd Service is Running\n\n"
        grep -Fx "docker-registry-mirror.kodekloud.com" /etc/containerd/config.toml
        if [ $? -eq 0 ]; then
            print_color "green" "Config File Entry Exists at /etc/containerd/config.toml"
            pull_image nginx
        fi
    else  #This is for K3s Cluster
        print_color "red" "\n\n\n Containerd Service is Not Running | Not Exist | Not Installed \n \n \n "
        print_color "red" "Config File Entry Does Not Exist in /etc/containerd/config.toml. Checking in /var/lib/rancher/k3s/agent/etc/containerd/certs.d"
        ls -l /var/lib/rancher/k3s/agent/etc/containerd/certs.d | grep -Fx "docker-registry-mirror.kodekloud.com"
        pull_image nginx
    fi
fi

echo "==================================== \n Docker Pull Test Completed \n -Iamrushabhshahh- \n===================================="