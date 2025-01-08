#!/bin/bash

set -e

# Prevent execution on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "This script is not supported on macOS."
    exit 1
fi

echo "Starting Kiosk setup..."

# Update package lists and install packages based on the package manager
if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y xorg xinit curl
elif command -v yum &> /dev/null; then
    sudo yum install -y xorg-x11-server-Xorg xorg-x11-xinit xorg-x11-apps curl
elif command -v zypper &> /dev/null; then
    sudo zypper refresh
    sudo zypper install -y xorg-x11-server xinit xorg-x11-apps curl
elif command -v pacman &> /dev/null; then
    sudo pacman -Syu --noconfirm xorg-server xorg-xinit xorg-xinit
elif command -v apk &> /dev/null; then
    sudo apk update
    sudo apk add xorg-server xinit xorg-server-utils curl
else
    echo "Unsupported package manager. Please install xorg, xinit, and curl manually."
    exit 1
fi

# Install Google Chrome
if ! command -v google-chrome &> /dev/null
then
    echo "Google Chrome not found. Installing..."
    if command -v apt &> /dev/null; then
        curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install -y ./google-chrome-stable_current_amd64.deb
        rm google-chrome-stable_current_amd64.deb
    elif command -v yum &> /dev/null; then
        sudo yum install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    elif command -v pacman &> /dev/null; then
        if ! command -v yay &> /dev/null; then
            echo "yay not found. Installing yay..."
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
            cd ..
            rm -rf yay
        fi
        yay -S --noconfirm google-chrome
    elif command -v apk &> /dev/null; then
        curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apk add --allow-untrusted ./google-chrome-stable_current_amd64.deb
        rm google-chrome-stable_current_amd64.deb
    fi
else
    echo "Google Chrome already installed."
fi

# Create .xinitrc
cat > ~/.xinitrc <<EOL
#!/bin/sh

# Disable screen saver and power management
xset s off
xset -dpms
xset s noblank

# Start Google Chrome in kiosk mode
exec google-chrome --kiosk --no-first-run --no-default-browser-check
EOL

chmod +x ~/.xinitrc

# Optional: Automate X startup on boot by modifying .bash_profile
if ! grep -q "startx" ~/.bash_profile; then
    echo 'if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx
fi' >> ~/.bash_profile
    echo "Added startx to ~/.bash_profile"
else
    echo "startx already in ~/.bash_profile"
fi

echo "Kiosk setup completed. Reboot or switch to tty1 and login to start the kiosk."
