#!/usr/bin/env bash

#####install kubernetes on ubuntu 20.04
### Only support ubuntu 

HOST_NAME=${HOST_NMAE:-MASTER}


###############
#   main function
###############

echo "### Installing Docker"
sudo apt update
sudo apt install -y docker.io
docker --version
sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER
newgrp docker &




echo "### Installing Kubernetes components"
sudo apt update
sudo apt install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add


echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sudo mv ~/kubernetes.list /etc/apt/sources.list.d


sudo apt update

sudo apt install -y kubeadm kubectl kubernetes-cni kubelet=1.25.5-00 


echo "### Configuring machine to meet kubernetes requirements"

sudo hostnamectl set-hostname ${HOST_NAME}

sudo swapoff -a
sudo ufw allow 6443
sudo ufw allow 6443/tcp

sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF

echo "### Done to install/config Kubernetes"
echo "### Please run kubeadm to init master or join nodes to existing cluster"
echo "    $ sudo kubeadm init --config [CONFIG-YAML]"
echo "    $ sudo kubeadm join [MASTER_IP]:6443 --token [TOKEN] --discovery-token-ca-cert-hash [CERT-HASH]] "
echo "### After kubeadm init successfully on master, Please install pod network"
echo "    $ kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml"