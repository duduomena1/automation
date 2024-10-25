#!/bin/bash
echo "Select OS:"
echo "1 - Debian"
echo "2 - Ubuntu"
echo "3 - Fedora"
echo "4 - Quit"
echo -n "Insert your option[1-5]: "

read choice

echo "👨🏻‍💻 Tell your user:"
read user

case $choice in
    1) echo "1 - Debian"
    echo "Update Debian"
    sudo apt update && sudo apt ugrade -y
    echo "Install Git"
    sudo apt-get install git-all
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
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo groupadd docker
    sudo usermod -aG docker $user
    echo "Install JDK"
    sudo apt update
    sudo apt install -y fontconfig openjdk-17-jre
    echo "Finish 🚀"
    echo "Restart System💀"
    sudo init 6
;;
    2) echo "2 - Ubuntu"
    echo "Update Debian"
    sudo apt update && sudo apt ugrade -y
    echo "Install Git"
    sudo apt-get install git-all
    echo "Remove/update Docker"
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
                sudo apt-get remove -y $pkg
            done
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo groupadd docker
    sudo usermod -aG docker $user
    echo "Install JDK"
    sudo apt update
    sudo apt install -y fontconfig openjdk-17-jre
    echo "Restarting System 💀"
    sudo init 6
;;
    3) echo "3 - Fedora"
    echo "Update Fedora"
    sudo dnf update && sudo dnf upgrade -y
    echo "Install Git"
    sudo dnf install git-all
    echo "install Docker"
    sudo dnf remove docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-selinux \
                      docker-engine-selinux \
                      docker-engine
    sudo dnf -y install dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
;;
    4) echo "Getting out 🏃💨"
    exit;;

    *) echo "Invalid choice 🤨";;
esac
