#!/bin/bash

echo "Update Distro"

sleep 2

sudo apt update && sudo apt upgrade -y

sleep 2

echo "Install Git"

sudo apt-get install -y git-all

echo "Remove/update Docker"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
            sudo apt-get remove -y $pkg
        done
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sleep 2

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Add User to Docker group"

sleep 2
sudo groupadd docker

sudo usermod -aG docker $USER

sudo echo "{
  "bip": "172.18.0.1/16",

  "log-driver": "json-file",
  "log-opts": {"max-size": "100m", "max-file": "3"},

  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}" > etc/docker/daemon.json 

sudo systemctl restart docker

echo "install Ansible"

sleep 2

sudo apt install ansible -y

echo "Finish 🚀"

sleep 3

echo "Restart System💀"
sudo init 6