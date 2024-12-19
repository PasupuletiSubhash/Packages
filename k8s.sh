#!/bin/bash
#Step3 :Apply server updates

sudo apt update 

#Step4 : Disable Swap: Kubernetes requires swap to be disabled.

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


#Step5: 

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#Installing containerd

wget https://github.com/containerd/containerd/releases/download/v1.7.21/containerd-1.7.21-linux-amd64.tar.gz

tar Cxzvf /usr/local containerd-1.7.21-linux-amd64.tar.gz

#systemd containerd service file download
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

#move the downloaded service file this location /usr/lib/systemd/system/

mv containerd.service /usr/lib/systemd/system/

# reload the containerd service 
systemctl daemon-reload
systemctl enable --now containerd


wget https://github.com/opencontainers/runc/releases/download/v1.1.13/runc.amd64


 install -m 755 runc.amd64 /usr/local/sbin/runc
 
#Installing CNI plugins

wget https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz

mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin/ cni-plugins-linux-amd64-v1.5.1.tgz

#Check required ports
#These required ports need to be open in order for Kubernetes components to #communicate with each other. You can use tools like netcat to check if a #port is open. For example:

nc 127.0.0.1 6443 -v

mkdir -p /etc/containerd/

#The default configuration can be generated via 

containerd config default > /etc/containerd/config.toml

#Edit the config.toml file line number 139

sudo sed -i '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml


# after edit restart the containerd

sudo systemctl restart containerd

#step 6: Installing kubeadm, kubectl and kubelet on all the nodes

	sudo apt-get update

# apt-transport-https may be a dummy package; if so, you can skip that package

	sudo apt-get install -y apt-transport-https ca-certificates curl gpg

#Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings

	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.31; for other Kubernetes minor versions
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list

	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:

	sudo apt-get update
	sudo apt-get install -y kubelet kubeadm kubectl
	sudo apt-mark hold kubelet kubeadm kubectl

#Enable the kubelet service before running kubeadm:
	
	sudo systemctl enable --now kubelet
