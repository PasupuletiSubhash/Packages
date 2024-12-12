#!/bin/bash

# Function to install Jenkins
install_jenkins() {
    echo "Installing Jenkins..."
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y openjdk-11-jdk curl gnupg
        curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
        echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
        sudo apt update
        sudo apt install -y jenkins
    elif [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS/Fedora
        sudo yum install -y java-11-openjdk curl
        curl --silent --location https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins > /dev/null
        sudo yum install -y https://pkg.jenkins.io/redhat-stable/jenkins-2.387.3-1.1.noarch.rpm
    else
        echo "Unsupported operating system."
        exit 1
    fi
    echo "Jenkins installation completed."
}

