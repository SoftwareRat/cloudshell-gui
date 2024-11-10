#!/bin/bash

# Update package lists and install necessary packages based on the distribution
if grep -q "Ubuntu" /etc/os-release; then
    sudo apt update
    sudo apt install -y xvfb xfce4 xfce4-goodies firefox plank papirus-icon-theme dbus-x11 neofetch
elif grep -q "Debian" /etc/os-release; then
    sudo apt update
    sudo apt install -y xvfb xfce4 xfce4-goodies firefox-esr plank papirus-icon-theme dbus-x11 neofetch
else
    echo "Unsupported distribution"
    exit 1
fi

# Download and install Chrome Remote Desktop
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i chrome-remote-desktop_current_amd64.deb
sudo apt --fix-broken install -y
rm chrome-remote-desktop_current_amd64.deb

# Install Catppuccin theme
sudo apt install -y sassc
git clone https://github.com/catppuccin/gtk.git
cd gtk
sudo make build
sudo make package
cd pkgs
sudo cp -r * /usr/share/themes
cd /usr/share/themes
~/install-catppuccin.sh

# Install Catppuccin Plank theme
cd
git clone https://github.com/catppuccin/plank.git
cd plank
sudo cp -r Catppuccin /usr/share/plank/themes
sudo cp -r Catppuccin-solid /usr/share/plank/themes
