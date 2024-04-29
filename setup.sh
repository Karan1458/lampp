#!/bin/bash

# Function to start the containers
start_containers() {
    # Check if the argument is "build-start"
    if [ "$1" == "build-start" ]; then
        # Clone latest tag of phpMyAdmin repository
        ./clone-latest-tag.sh https://github.com/phpmyadmin/phpmyadmin.git
        #git clone --depth 1 --branch $(git ls-remote --tags --sort="v:refname" --refs https://github.com/phpmyadmin/phpmyadmin.git | tail -n 1 | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+') https://github.com/phpmyadmin/phpmyadmin.git phpmyadmin

        # Clone another repository
        git clone https://github.com/Karan1458/playground.git playground

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
else
    echo "Usage: $0 [start|build-start|stop|destroy]"
fi