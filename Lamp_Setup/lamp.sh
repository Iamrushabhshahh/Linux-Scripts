#/bin/bash
#
# This script automate the lamp stack installation in Ubuntu and Rhel both enviornment.
# Author : Rushabh Shah
# E-mail : rushabhshah842@gmail.com


echo "===================================="
echo "            lamp Setup              "
echo "         -Iamrushabhshahh-          "
echo "===================================="


#######################################
# Print the message in gicen color.
# Arguments:
#   Color. eg: red,green
#######################################

function print_color () {
    case $1 in
        "green") COLOR="\033[92m";; 
        "red") COLOR="\033[31m";;
        "*")  COLOR="\033[0m";;
    esac
    echo -e "${COLOR} $2 ${NC}"
}


#######################################
# Check service status.
# Arguments:
#   Service Name. eg: nginx,apache2
#######################################

function check_service_status() {
    is_service_active=$(sudo systemctl is-active $1)
    if [ $is_service_active = "active" ] 
    then
        print_color "green" "$1 Service is active"
    else
        print_color "red" "$1 Service is Inactive"
        exit 1
    fi
}


#######################################
# Add firewall rule
# Arguments:
#   Port. eg: 80,443,22
#######################################

function add_firewall_rule() {
    port=$1
    sudo ufw allow $port/tcp
    echo "Added firewall rule for port $port"
}


#######################################
# Add firewall rule in Rhel and Cent Os
# Arguments:
#   Port. eg: 80,443,22
#######################################

function add_firewall_rule() {
    port=$1
    # Adjust this command based on the firewall utility used in CentOS/RHEL
    sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent
    sudo firewall-cmd --reload
    echo "Added firewall rule for port $port"
}


# Check if /etc/os-release exists
if [ -f /etc/os-release ]; then
    # Source the file to get the values
    . /etc/os-release

    # ============================================ UBUNTU - APT ================================================

    # Check if the ID matches "ubuntu"
    if [ "$ID" == "ubuntu" ]; then
        
        # Run apt command to upgrade and update the linux repo
        print_color "green" "Updating Linux Repo"
        sudo apt update -y 
        sudo apt upgrade -y
        clear
        # Turning on the firewall
        print_color "green" "Activating Firewall"
        sudo ufw enable

        # adding rule for ssh
        print_color "green" " Allowing the SSH rule for 22/tcp "
        add_firewall_rule 22

        check_service_status ufw
        clear
        
        # install mysql and enable it
        print_color "green" "Installing the mysql-server"
        sudo apt install mysql-server -y
        sudo systemctl enable mysql
        sudo systemctl start mysql
        
        
        check_service_status mysql

        # installing apache or nginx
        while true; 
        do
            print_color "red" "Chose one Web server to install"
            echo "1 : Apache2"
            echo "2 : Nginx"
            read -p "Enter your choice (1 or 2) : " choice

            case $choice in 
                1) print_color "green" "Installing Apache2"
                    sudo apt install -y apache2
                    sudo ufw allow 'Apache Full'
                    web_server="apache2"
                    break;;
                2) print_color "green" "Installing Nginx"
                    sudo apt install -y nginx
                    sudo ufw allow 'Nginx Full'
                    web_server="nginx"
                    break;;
                *) print_color "red" "Enter valid choice";;
            esac
        done

        check_service_status $web_server
        # Check the Service statsu
        
        # Installing the PHP and It's module
        print_color "green" "Installing PHP and it's module"
        sudo apt install php libapache2-mod-php php-mysql -y

        # Install git in system
        print_color "green" "installling git"
        sudo apt install git -y

        # Check the Version of php
        echo "======================="
        echo "     PHP-VERSION       "
        echo "======================="
        php -v

        status=$(curl --silent --head http://localhost | awk '/^HTTP/{print $2}')

        if [ $status -eq 200 ]
        then 
            print_color "green" "LAMP successfully setted up"
        fi 
    
   # ============================================ CENTOS - YUM ================================================


    else
        
        # Run yum command
        print_color "green" "Updating Linux Repo"
        sudo yum update -y
        sudo yum upgrade -y

        # Installing and setting up the firewalld
        print_color "green" "Activating the firewalld"
        sudo yum install -y firewalld
        sudo systemctl start firewalld
        sudo systemctl enable firewalld
        
        check_service_status firewalld

        #Installing the mariadb
        print_color "green" "Installing maria-db"
        sudo yum install -y mariadb-server
            #sudo vi /etc/my.cnf
        sudo systemctl start mariadb
        sudo systemctl enable mariadb

        check_service_status mariadb
        # installing webserver
        
        while true; 
        do
            print_color "red" "Choose one Web server to install"
            echo "1 : Apache2 (httpd)"
            echo "2 : Nginx"
            read -p "Enter your choice (1 or 2) : " choice

            case $choice in
                1)  print_color "green" "Installing apache2 ( httpd ) "
                    sudo yum install -y httpd
                    sudo systemctl start httpd
                    sudo systemctl enable httpd
                    web_server="httpd"
                    break;;
                2)  print_color "green" "Installing nginx"
                    sudo yum install -y nginx
                    sudo systemctl start nginx
                    sudo systemctl enable nginx
                    web_server="nginx"
                    break;;
                *)  print_color "red" "Enter valid choice";;
            esac
        done

        check_service_status $web_server

        add_firewall_rule 80
        add_firewall_rule 443

        # Setting up Php and other dependencies
        print_color "green" "Installing PHP and it's module"
        sudo yum install -y php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mbstring php-curl php-xml php-pear php-bcmath
        # Setting Index.php as priority rather then index.html
        # sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf


        # install the latest version of gitclear
         print_color "green" "Installing git"
        sudo yum install -y git

        # Check the Version of php
        echo "======================="
        echo "     PHP-VERSION       "
        echo "======================="
        php -v

        # This will curl and give us the output that it's live or not
        status=$(curl --silent --head http://localhost | awk '/^HTTP/{print $2}')

        if [ $status -eq 200 ]
        then 
            print_color "green" "LAMP successfully setted up"
        fi 
    

    fi
fi
