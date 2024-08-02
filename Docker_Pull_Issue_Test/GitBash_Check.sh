#!/bin/bash 
# This script is for the checking os-release
# Authored by Rushabh Shaah
# Email : rushabh@kodekloud.com

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
# check the os-release file
#######################################

function os_checkup {
    if [ -f /etc/os-release ]; then
        # Extract the VERSION_ID and PRETTY_NAME from the os-release file
        version_id=$(grep 'VERSION_ID' /etc/os-release | cut -d '=' -f2 | tr -d '"')
        os_name=$(grep 'PRETTY_NAME' /etc/os-release | cut -d '=' -f2 | tr -d '"')

        # Print the OS name and VERSION_ID
        print_color green "OS: $os_name"
        print_color green "Version : $version_id"
    else
        echo "The /etc/os-release file does not exist. Unable to determine OS version."
    fi
}

#######################################
# Docker Chekcup Function
#######################################

function docker_check {
        if command -v docker >/dev/null; then
            print_color "green" " \n Docker is Installed $(docker --version) \n"
            if grep "${MIRROR_REPO}" /etc/docker/daemon.json >/dev/null; then
                print_color "green" " \n Mirror repo found in /etc/docker/daemon.json"
                print_color "green" " \n Checking For Docker Pull"
                if docker pull redis; then
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
}

#######################################
# Main Function
#######################################
function main() {
    os_checkup
    sudo systemctl is_active docker &>/dev/null
    if [ $? -ne 0 ]; then
        print_color "red" "Docker is not running"
        sudo systemctl start docker
        if [ $? -eq 0 ]; then
            print_color "green" "Docker started successfully"
            docker_check
        else
            print_color "red" "Failed to start Docker"
        fi
    else
        print_color "green" "Docker is running"
    fi
}
