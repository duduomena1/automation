#!bin/bash
echo "Install warp"
sudo rpm --import https://releases.warp.dev/linux/keys/warp.asc
sudo sh -c 'echo -e "[warpdotdev]\nname=warpdotdev\nbaseurl=https://releases.warp.dev/linux/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://releases.warp.dev/linux/keys/warp.asc" > /etc/yum.repos.d/warpdotdev.repo'
sudo dnf install -y warp-terminal

echo "Install ZED"

curl -f https://zed.dev/install.sh | sh

echo "Install GitKraken"
flatpak install -y flathub com.axosoft.GitKraken

echo "Install Obsidian"
flatpak install -y flathub md.obsidian.Obsidian

echo "Install spotify"
flatpak install -y flathub com.spotify.Client

echo "Install Brave"
flatpak install -y flathub com.brave.Browser

echo "Install VScode"
flatpak install -y flathub com.visualstudio.code
