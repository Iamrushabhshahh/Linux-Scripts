#!/bin/bash
#
# This script automates Docker Pull Issue check
# Author : Rushabh Shah
# E-mail : rushabh@kodekloud.com

echo "===================================="
echo "         Docker Pull Test           "
echo "         -Iamrushabhshahh-          "
echo "===================================="

MIRROR_REPO=docker-registry-mirror.kodekloud.com
MIRROR_ADDR=10.0.0.6

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
    if  [ ! -z $(kubectl  get po -o json | jq -r '.items[] | select(.metadata.name == "'$1'") | .metadata.name') ]
    then
        print_color "green" " \n Pod $1 exists. Deleting it..."
        kubectl delete pod "$1"
    else
        print_color "green" "\n Pod $1 does not exist."
    fi
    print_color "green" "Pulling $1 Image and Running it \n"

    # Ensure it always makes a call to the remote registry
    kubectl run $1 --image=$1 --image-pull-policy Always

    # We don't guess how long it takes a pod to be ready. We ask API server :-)
    if kubectl wait pod $1 --for condition=Ready --timeout 30s
    then
        print_color "green" " Pod $1 started successfully"
        kubectl get pod $1
        kubectl delete pod $1
    else
        print_color "red" " Pod $1 has not started"
        kubectl get pod
    fi
}

# Check Host Entries for Docker Registry | Check this for all Enviornments
print_color "green" "\n Checking Host Entries for Docker Registry \n"
if egrep "${MIRROR_ADDR}\s+${MIRROR_REPO}" /etc/hosts > /dev/null
then
    print_color "green" " \n Hosts File Entry Exists \n"
else
    print_color "red" "\n Hosts File Entry Does Not Exist \n"
    # Stop here since if the host doesn't exist, nothing will work!
    exit 1
fi

if command -v docker > /dev/null
then
    print_color "green" " \n Docker is Installed $(docker --version) \n"
    if grep "${MIRROR_REPO}" /etc/docker/daemon.json > /dev/null
    then
        print_color "green" " \n Mirror repo found in /etc/docker/daemon.json"
        print_color "green" " \n Checking For Docker Pull"
        if docker pull redis
        then
            print_color "green" "Pull successful"
        else
            print_color "red" "Pull FAILED"
        fi
    else
        print_color "red" " \n Mirror repo NOT FOUND in /etc/docker/daemon.json"
    fi
else
    print_color "red" "\n Docker is Not Installed"
fi

# It is surely possible to have both kube and docker installed in a lab or playground
# where a user might want to build an image, then deploy to cluster.
if command -v kubectl > /dev/null
then
    print_color green "kubectl detected. Examining kubernetes"
    K8S_CONFIG=""
    if command -v systemctl > /dev/null
    then
        if systemctl status containerd.service >/dev/null
        then
            print_color green "Kubernetes: kubeadm"
            K8S_CONFIG=/etc/containerd/config.toml
        fi
    fi
    if [ -z $K8S_CONFIG ]
    then
        print_color green "Kubernetes: K3S"
        K8S_CONFIG=/var/lib/rancher/k3s/agent/etc/containerd/certs.d/docker-registry-mirror.kodekloud.com/hosts.toml
        [ -f $K8S_CONFIG ] || K8S_CONFIG=/var/lib/rancher/k3s/agent/etc/containerd/config.toml
    fi

    if grep $MIRROR_REPO $K8S_CONFIG > /dev/null
    then
        print_color "green" "\n Mirror repo found in ${K8S_CONFIG} - testing pull"
        pull_image nginx
    else
        print_color "red" "\n Mirror repo NOT FOUND in ${K8S_CONFIG}"
    fi
else
    print_color green "kubectl not found. Assuming no kubernetes in ths lab."
fi


print_color "green" "\n Rate Limit Check From Docker \n"
TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
curl -Is -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest > rate.tmp
echo "- Limit: $(cat rate.tmp | awk '/ratelimit-limit:/ { print $2 }' | cut -d ';' -f 1)"
echo "- Remaining: $(cat rate.tmp | awk '/ratelimit-remaining:/ { print $2 }' | cut -d ';' -f 1)"
echo "- Public IP: $(cat rate.tmp | awk '/docker-ratelimit-source:/ { print $2 }')"
echo
rm -f rate.tmp
print_color "green" "\n===================================="
print_color "green" "     Docker Pull Test Completed     "
print_color "green" "         -Iamrushabhshahh-          "
print_color "green" "===================================="
