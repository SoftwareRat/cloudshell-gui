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
    if [ ! -d "$HOME/.cloudshell" ] && [ ! -f "$HOME/.cloudshell/no-apt-get-warning" ]; then
        mkdir "$HOME/.cloudshell" && touch "$HOME/.cloudshell/no-apt-get-warning"
    fi
    sudo apt-get update -y
}

# Function to install essential packages
install_packages() {
    echo "Installing essential packages..."
    sudo apt-get install -y xfce4 xvfb dbus-x11 neofetch firefox wget
}

# Function to install Chrome Remote Desktop
install_chrome_remote_desktop() {
    echo "Installing Chrome Remote Desktop..."
    # Download the latest Chrome Remote Desktop .deb package
    wget -O /tmp/chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    # Install the package
    sudo dpkg -i /tmp/chrome-remote-desktop_current_amd64.deb || sudo apt-get install -f -y
    # Remove the downloaded package
    rm /tmp/chrome-remote-desktop_current_amd64.deb
    echo "Chrome Remote Desktop installed successfully."
}

# Function to configure Chrome Remote Desktop for instant connection
configure_chrome_remote_desktop() {
    echo "Configuring Chrome Remote Desktop for instant connection..."

    # Set the desktop environment for Chrome Remote Desktop
    echo "exec /usr/sbin/lightdm-session startxfce4" > ~/.chrome-remote-desktop-session

    # Prompt the user to enter the Chrome Remote Desktop code
    read -p "Enter your Chrome Remote Desktop code: " CRD_CODE

    # Execute the Chrome Remote Desktop start-host command with the provided code
    DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="$CRD_CODE" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)
    echo "Chrome Remote Desktop configured to start on boot."
}

# Function to install Envi theme
install_envi_theme() {
    echo "Installing Envi theme..."
    wget -O /tmp/Envi-theme.tar.gz https://github.com/toorandomenvi/Envi-Theme/raw/master/Envi-theme-1.0.tar.gz
    tar -xzf /tmp/Envi-theme.tar.gz -C /tmp/
    sudo cp -r /tmp/Envi-theme/* /usr/share/themes/
    rm -rf /tmp/Envi-theme /tmp/Envi-theme.tar.gz
    echo "Envi theme installed successfully."
}

# Function to remove unnecessary multimedia applications
remove_multimedia_apps() {
    echo "Removing unnecessary multimedia applications..."
    sudo apt-get purge -y rhythmbox gnome-music
    sudo apt-get autoremove -y
    echo "Unnecessary multimedia applications removed."
}

# Function to clean up
cleanup() {
    echo "Cleaning up..."
    sudo apt-get clean
    echo "Cleanup completed."
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
    install_chrome_remote_desktop
    configure_chrome_remote_desktop
    install_envi_theme
    remove_multimedia_apps
    cleanup
    feedback "Setup and Chrome Remote Desktop configuration completed successfully."
}

# Execute the main function
main