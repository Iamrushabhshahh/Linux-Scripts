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

function print_color() {
    case $1 in
    "green") COLOR="\033[92m" ;;
    "red") COLOR="\033[31m" ;;
    "*") COLOR="\033[0m" ;; # default color
    esac
    echo -e "${COLOR} $2 \033[0m"
}

#######################################
# Pull and run image
# Arguments:
#   Image name. eg: nginx, redis
#######################################

function pull_image() {
    if kubectl get pods | grep -q "$1"; then
        print_color "green" " \n Pod $1 exists. Deleting it..."
        kubectl delete pod "$1"
        print_color "green" "\n Pod $1 has been deleted."
    else
        print_color "green" "\n Pod $1 does not exist. \n Pulling $1 Image and Running it \n"
    fi
    kubectl run $1 --image=$1
    sleep 10
    print_color "green" " \n"
    kubectl get pod
}

# Check Host Entries for Docker Registry | Check this for all Enviornments
print_color "green" "\n Checking Host Entries for Docker Registry \n"
grep "10.0.0.6 docker-registry-mirror.kodekloud.com" /etc/hosts
if [ $? -eq 0 ]; then
    print_color "green" " \n Hosts File Entry Exists \n"
else
    print_color "red" "\n Hosts File Entry Does Not Exist \n"
fi

# CHECK DOCKER
which docker
if [ $? -eq 0 ]; then
    print_color "green" " \n Docker is Installed $(docker --version) \n"
    cat /etc/docker/daemon.json | grep "docker-registry-mirror.kodekloud.com"
    if [ $? -eq 0 ]; then
        print_color "green" " \n Config File Entry Exists at /etc/docker/daemon.json"
        print_color "green" " \n Checking For Docker Pull"
        # docker run docker/whalesay KodeKloud #Chcecking Docker pull
        docker pull redis  
    else
        print_color "red" " \n Config File Doesn't have the docker repository link \n"
        cat /etc/docker/daemon.json
    fi
else
    print_color "red" "\n Docker is Not Installed"
    print_color "green" "\n Checking For Kubernetes"
    # CHECK KUBERNETES CLUSTER
    kubectl get all
    systemctl status containerd.service >/dev/null # Check if containerd is running
    if [ $? -eq 0 ]; then
        print_color "green" "\n Containerd Service is Running"
        grep "docker-registry-mirror.kodekloud.com" /etc/containerd/config.toml
        if [ $? -eq 0 ]; then
            print_color "green" "\n Config File Entry Exists at /etc/containerd/config.toml"
            pull_image nginx
        else
            print_color "red" "\n Config.toml Doesn't have the docker repository link \n"
            pull_image nginx
        fi
    else
        print_color "red" "\nContainerd Service is Not Running | This Might K3s Node "
        print_color "green" "\n Checking in /var/lib/rancher/k3s/agent/etc/containerd/certs.d \n"
        ls -l /var/lib/rancher/k3s/agent/etc/containerd/certs.d | grep "docker-registry-mirror.kodekloud.com"
        if [ $? -eq 0 ]; then
            print_color "green" "\n Config File Entry Exists at /var/lib/rancher/k3s/agent/etc/containerd/certs.d \n"
            ls -l /var/lib/rancher/k3s/agent/etc/containerd/certs.d
            pull_image nginx
        else
            print_color "red" "\n Certs.d Doesn't have the docker repository link \n"
            cat /var/lib/rancher/k3s/agent/etc/containerd/config.toml | grep "docker-registry-mirror.kodekloud.com"
            if [ $? -eq 0 ]; then
                print_color "green" "Config File Entry Exists at /var/lib/rancher/k3s/agent/etc/containerd/config.toml"
                pull_image nginx
            else
                print_color "red" "Config.toml Doesn't have the docker repository link \n"
                ls -l /var/lib/rancher/k3s/agent/etc/containerd/
                pull_image nginx
            fi
        fi
    fi
fi

print_color "green" "\n Rate Limit Check From Docker \n"
TOKEN=$(curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
print_color "green" "Below is the Count \n"
curl --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest


print_color "green" "\n===================================="
print_color "green" "     Docker Pull Test Completed     "
print_color "green" "         -Iamrushabhshahh-          "
print_color "green" "===================================="
