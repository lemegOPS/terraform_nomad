#!/bin/bash
#----- System prepare -----#
sudo yum update -y
sudo yum install -y git docker go vi jq
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#----- Docker\Docker-compose install -----#
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

#----- Nomad install -----#
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install nomad

curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz && \
sudo mkdir -p /opt/cni/bin && \
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables && \
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables && \
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables


cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo modprobe br_netfilter
sudo sysctl --system
sudo swapoff -a

sudo systemctl enable nomad
sudo systemctl start nomad
