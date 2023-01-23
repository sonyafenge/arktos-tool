#!/usr/bin/env bash

#####install kubernetes on ubuntu 20.04
### Only support ubuntu 

HOST_NAME=${HOST_NAME:-master}


###############
#   main function
###############


echo “HOST_NAME:$HOST_NAME”
echo "### Installing Kubernetes components"
sudo apt update
sudo apt install -y apt-transport-https gnupg2 curl ca-certificates lsb-release
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add


echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sudo mv ~/kubernetes.list /etc/apt/sources.list.d


sudo apt update

sudo apt install -y kubeadm=1.25.5-00 kubectl=1.25.5-00 kubernetes-cni kubelet=1.25.5-00 


echo "### Installing Docker"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt-get remove containerd.io 
#sudo apt install -y docker.io 
sudo apt install -y containerd.io
#docker --version
containerd --version


#sudo chmod o+rw /var/run/docker.sock
#sudo usermod -aG docker $USER
#newgrp docker &


echo "### Configuring machine to meet kubernetes requirements"

sudo hostnamectl set-hostname ${HOST_NAME}

sudo swapoff -a
sudo ufw allow 6443
sudo ufw allow 6443/tcp

sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo sysctl net.ipv4.ip_forward=1

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF

sudo rm /etc/containerd/config.toml
#sudo systemctl enable docker
sudo systemctl enable containerd
sudo systemctl daemon-reload
#sudo systemctl restart docker
sudo systemctl restart containerd
sudo systemctl restart kubelet

echo "### Done to install/config Kubernetes"
echo "### Please run kubeadm to init master or join nodes to existing cluster"
echo "    $ sudo kubeadm init --config [CONFIG-YAML]"
echo "    $ sudo kubeadm join [MASTER_IP]:6443 --token [TOKEN] --discovery-token-ca-cert-hash [CERT-HASH]] "
echo "### After kubeadm init successfully on master, Please install pod network"
echo "    $ kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml"