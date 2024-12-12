#!/bin/bash

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y ca-certificates curl gnupg
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
    elif [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS/Fedora
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
    else
        echo "Unsupported operating system."
        exit 1
    fi

    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    # Change permissions on the Docker socket
    echo "Setting permissions on /var/run/docker.sock..."
    sudo chmod 777 /var/run/docker.sock

    echo "Docker installation completed with universal socket access."
}

