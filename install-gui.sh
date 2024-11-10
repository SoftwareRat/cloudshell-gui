#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if the OS is Ubuntu or Debian
detect_os() {
    if [[ -e /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            OS="Ubuntu"
        elif [[ "$ID" == "debian" ]]; then
            OS="Debian"
        else
            echo "Unsupported OS: $ID"
            exit 1
        fi
    else
        echo "Cannot determine the operating system."
        exit 1
    fi
    echo "Detected OS: $OS"
}

# Function to update package lists
update_packages() {
    echo "Updating package lists..."
    sudo apt-get update -y
}

# Function to install essential packages
install_packages() {
    echo "Installing essential packages..."
    sudo apt-get install -y xfce4 Xvfb dbus-x11 neofetch firefox
}

# Function to install RustDesk
install_rustdesk() {
    echo "Installing RustDesk..."
    local latest_deb
    latest_deb=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep "browser_download_url.*deb" | cut -d '"' -f 4)
    wget -O /tmp/rustdesk.deb "$latest_deb"
    sudo dpkg -i /tmp/rustdesk.deb || sudo apt-get install -f -y
    rm /tmp/rustdesk.deb
}

# Function to configure RustDesk for instant connection
configure_rustdesk() {
    echo "Configuring RustDesk for instant connection..."
    
    # Enable RustDesk to start on boot
    systemctl --user enable rustdesk
    systemctl --user start rustdesk

    read -sp "Enter RustDesk password: " RUST_DESK_PASSWORD
    echo
    mkdir -p ~/.config/RustDesk
    echo "{\"password\":\"$RUST_DESK_PASSWORD\"}" > ~/.config/RustDesk/config.json

    echo "RustDesk configured to start on boot."
}

# Function to install Envi theme
install_envi_theme() {
    echo "Installing Envi theme..."
    wget -O /tmp/Envi-theme.tar.gz https://github.com/toorandomenvi/Envi-Theme/raw/master/Envi-theme-1.0.tar.gz
    tar -xzf /tmp/Envi-theme.tar.gz -C /tmp/
    sudo cp -r /tmp/Envi-theme/* /usr/share/themes/
    rm -rf /tmp/Envi-theme /tmp/Envi-theme.tar.gz
}

# Function to remove unnecessary multimedia applications
remove_multimedia_apps() {
    echo "Removing unnecessary multimedia applications..."
    sudo apt-get purge -y rhythmbox gnome-music
    sudo apt-get autoremove -y
}

# Function to clean up
cleanup() {
    echo "Cleaning up..."
    sudo apt-get clean
}

# Function to provide user feedback
feedback() {
    echo "$1"
}

# Main function to orchestrate the script
main() {
    detect_os
    update_packages
    install_packages
    install_browser
    install_rustdesk
    configure_rustdesk
    install_envi_theme
    remove_multimedia_apps
    cleanup
    feedback "Setup and RustDesk configuration completed successfully."
}

# Execute the main function
main