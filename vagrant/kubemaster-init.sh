#!/bin/bash

## Set variables values
MASTER_IP=192.168.56.3

lsmod | grep br_netfilter
sudo modprobe br_netfilter
lsmod | grep br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

## INSTALLING DOCKER ENGINE BASED ON OS

yum --help &>> /dev/null
if [ $? -eq 0 ]
then
  # (Install Docker CE)
  ## Set up the repository
  ### Install required packages
  yum install -y yum-utils device-mapper-persistent-data lvm2
  ## Add the Docker repository
  yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
  # Install Docker CE
  yum update -y && yum install -y \
    containerd.io-1.2.13 \
    docker-ce-19.03.11 \
    docker-ce-cli-19.03.11
  ## Create /etc/docker
  mkdir /etc/docker
  # Set up the Docker daemon
  cat > /etc/docker/daemon.json <<EOF
  {
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
      "overlay2.override_kernel_check=true"
    ]
  }
EOF
  mkdir -p /etc/systemd/system/docker.service.d
  # Restart Docker
  systemctl daemon-reload
  systemctl restart docker
  sudo systemctl enable docker

else
  # (Install Docker CE)
  ## Set up the repository:
  ### Install packages to allow apt to use a repository over HTTPS
  apt-get update && apt-get install -y \
    apt-transport-https ca-certificates curl software-properties-common gnupg2
  # Add Docker's official GPG key:
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  # Add the Docker apt repository:
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  # Install Docker CE
  apt-get update && apt-get install -y \
    containerd.io=1.2.13-2 \
    docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
    docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)
  # Set up the Docker daemon
  cat > /etc/docker/daemon.json <<EOF
  {
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "storage-driver": "overlay2"
  }
EOF
  mkdir -p /etc/systemd/system/docker.service.d
  # Restart Docker
  systemctl daemon-reload
  systemctl restart docker
  sudo systemctl enable docker

fi

sleep 30

## Installing kubeadm, kubelet and kubectl
yum --help &>> /dev/null
if [ $? -eq 0 ]
then
   cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
   [kubernetes]
   name=Kubernetes
   baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
   exclude=kubelet kubeadm kubectl
EOF

   # Set SELinux in permissive mode (effectively disabling it)
   sudo setenforce 0
   sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

   sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

   sudo systemctl enable --now kubelet
   systemctl stop firewalld
   systemctl disable firewalld

else

   sudo apt-get update && sudo apt-get install -y apt-transport-https curl
   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
   cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
   deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
   sudo apt-get update
   sudo apt-get install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
   systemctl stop ufw
   systemctl disable ufw
fi

#sleep 30

#sudo sed -i '/^disabled_plugins/s/^/#/' /etc/containerd/config.toml
#sudo rm /etc/containerd/config.toml
#sudo sed -i 's/^disabled_plugins/enabled_plugins/' /etc/containerd/config.toml
sudo apt install containerd.io -y
sudo sed -i '/^disabled_plugins/s/"cri"/ /' /etc/containerd/config.toml
sudo systemctl restart containerd
sleep 10
sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.3 --v=5 > /tmp/kubeadm_out.log
sleep 60
#/vagrant/set-kubeconfig.sh
#we now run the command from the set-kubeconfig.sh script
sudo mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant.vagrant /home/vagrant/.kube
sudo mkdir -p /root/.kube
sudo cp -f /etc/kubernetes/admin.conf /root/.kube/config
sudo chown -R root.root /root/.kube
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#end of commands

#below command is deprecated
#sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
sudo kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
sleep 60
sudo cat /tmp/kubeadm_out.log | grep -A1 'kubeadm join' > /vagrant/cltjoincommand.sh
sudo chmod +x /vagrant/cltjoincommand.sh


#install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

#also tree for funsies
sudo apt install tree