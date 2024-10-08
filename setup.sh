#!/bin/bash

#!/bin/bash

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Absolute paths for commands
CAT="/bin/cat"
TEE="/usr/bin/tee"
SED="/usr/bin/sed"
SUDO="/usr/bin/sudo"
GREP="/usr/bin/grep"
AWK="/usr/bin/awk"

# Get your host's UID and GID
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)
export HOST_USER=$(whoami)

# Function to install Docker CE
install_docker_ce() {
    # Update the apt package index
    $SUDO apt-get update

    # Install packages to allow apt to use a repository over HTTPS
    $SUDO apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO apt-key add -

    # Set up the stable repository
    $SUDO add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Update the apt package index
    $SUDO apt-get update

    # Install Docker CE
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io
}

# Function to install Docker Compose
install_docker_compose() {
    # Download the current stable release of Docker Compose
    $SUDO curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Apply executable permissions to the Docker Compose binary
    $SUDO chmod +x /usr/local/bin/docker-compose
}

# Function to install Docker and Docker Compose if not installed
install_docker_and_compose() {
    # Check if Docker is installed
    if ! command_exists docker; then
        echo "Installing Docker CE..."
        install_docker_ce
    else
        echo "Docker CE is already installed."
    fi

    # Check if Docker Compose is installed
    if ! command_exists docker-compose; then
        echo "Installing Docker Compose..."
        install_docker_compose
    else
        echo "Docker Compose is already installed."
    fi
}

# Function to update /etc/hosts file
update_hosts_file() {
    DOMAIN=$1
    echo "Check $DOMAIN in hosts file"
    # Define the IP address and hostname
    IP_ADDRESS="127.0.0.1"

    # Check if the entry already exists in /etc/hosts
    #if grep -qFx "$IP_ADDRESS $DOMAIN.test" /etc/hosts; then
    if $SUDO $GREP -q "^$IP_ADDRESS[[:space:]]\+$DOMAIN\.test\$" /etc/hosts; then
        echo "Entry already exists in /etc/hosts. Skipping..."
    else
        # Add .test domain entry to /etc/hosts file
        echo "$IP_ADDRESS $DOMAIN.test" | $SUDO $TEE -a /etc/hosts >/dev/null
        echo "Entry added to /etc/hosts."
    fi
}

# Function to add site configuration for Nginx
add_site() {
    DOMAIN=$1
    PATH=$2

    # Check if the Nginx site configuration file already exists
    if [ -e "nginx/sites/$DOMAIN.conf" ]; then
        echo "Nginx site configuration file already exists. Skipping..."
    else
        # Create nginx configuration file
        $SUDO $CAT << 'EOF' > nginx/sites/$DOMAIN.conf
server {
    listen 80;
    server_name $DOMAIN.test;
    root /var/www/$PATH;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    # Cache Static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
        # Replace $uri, $DOMAIN, and $PATH in nginx config
        $SED -i "s|\$DOMAIN|$DOMAIN|g; s|\$PATH|$PATH|g" "nginx/sites/$DOMAIN.conf"
    fi

    # Update /etc/hosts file
    update_hosts_file $DOMAIN

    echo "Site configuration added for $DOMAIN"
}

# Function to remove site configuration for Nginx
remove_site() {
    DOMAIN=$1

    # Remove nginx configuration file
    rm -f nginx/sites/$DOMAIN.conf

    # Remove .test domain entry from /etc/hosts file
    $SUDO sed -i "/$DOMAIN.test/d" /etc/hosts

    echo "Site configuration removed for $DOMAIN"
}

# Function to start the containers
start_containers() {
    # Check if Docker and Docker Compose are installed
    install_docker_and_compose

    # Check if the argument is "build-start"
    if [ "$1" == "build-start" ]; then
        # Check if phpMyAdmin folder exists
        if [ -d "./phpmyadmin" ]; then
            echo "PHPmyAdmin folder already exists. Skipping..."
        else
            # Clone latest tag of phpMyAdmin repository
            #./clone-latest-tag.sh https://github.com/phpmyadmin/phpmyadmin.git
            URL="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz";
            DEST_FOLDER="phpmyadmin"
            HOST='mysql'
            mkdir -p "$DEST_FOLDER"; wget -qO- "$URL" | tar -xzf- -C "$DEST_FOLDER" --strip-components=1

            # Copy config.sample.inc.php to config.inc.php
            cp "$DEST_FOLDER/config.sample.inc.php" "$DEST_FOLDER/config.inc.php"

            # Update host value in config.inc.php
            sed -i "s/\(\$cfg\['Servers'\]\[\$i\]\['host'\] = '\)[^']*'/\1$HOST'/g" "$DEST_FOLDER/config.inc.php"
            #git clone --depth 1 --branch $(git ls-remote --tags --sort="v:refname" --refs https://github.com/phpmyadmin/phpmyadmin.git | tail -n 1 | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+') https://github.com/phpmyadmin/phpmyadmin.git phpmyadmin
        fi

        # Check if phpMyAdmin folder exists
        if [ -d "./playground" ]; then
            echo "PHP Playground folder already exists. Skipping..."
        else
             # Clone another repository
            git clone https://github.com/Karan1458/playground.git playground
        fi

        # Update /etc/hosts file
        update_hosts_file "phpmyadmin"
        update_hosts_file "playground"
        update_hosts_file "mailhog"

        # Start docker-compose
        docker-compose up --build -d
    else
        # Start docker-compose without build
        docker-compose up -d
    fi

   
}

# Function to stop the containers
stop_containers() {
    docker-compose down
}

# Function to destroy containers, volumes, and networks
destroy_all() {
    read -p "This will destroy all containers, volumes, and networks. Are you sure? [y/n]: " confirm
    if [ "$confirm" == "y" ]; then
        # Stop and remove containers, volumes, and networks
        docker-compose down --volumes --remove-orphans
        
        # Remove phpMyAdmin folder
        rm -rf phpmyadmin

        # Remote playground folder
        rm -rf playground

        # Remove .test domain entry from /etc/hosts file
        $SUDO sed -i "/playground.test/d" /etc/hosts
        $SUDO sed -i "/phpmyadmin.test/d" /etc/hosts
        $SUDO sed -i "/mailhog.test/d" /etc/hosts

    else
        echo "Destroy cancelled."
    fi
}

# Check for argument
if [ "$1" == "start" ] || [ "$1" == "build-start" ]; then
    start_containers $1
elif [ "$1" == "stop" ]; then
    stop_containers
elif [ "$1" == "destroy" ]; then
    destroy_all
elif [ "$1" == "add-site" ]; then
    if [ -z "$2" ] || [ -z "$3" ]; then
        echo "Usage: $0 add-site domain_name path"
    else
        add_site $2 $3
    fi
elif [ "$1" == "remove-site" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 remove-site domain_name"
    else
        remove_site $2
    fi
elif [ "$1" == "update-hosts" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 update-hosts domain_name"
    else
        update_hosts_file $2
    fi
else
    echo "Usage: $0 [start|build-start|stop|destroy|add-site|remove-site|update-hosts] domain_name path"
fi