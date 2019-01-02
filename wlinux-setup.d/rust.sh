#!/bin/bash

source "/etc/wlinux-setup.d/common.sh"

if (whiptail --title "RUST" --yesno "Would you like to download and install the latest version of Rust via rustup?" 8 85) then
    echo "Installing rust"

    # Create temp directory and download rustup installer here
    createtmp
    echo "Downloading and latest version of rustup installer"
    wget https://sh.rustup.rs -O rustup.rs

    echo "Executing..."
    chmod +x rustup.rs
    sh rustup.rs -y

    # Cleanup
    echo "Cleaning up rustup temporary folder"
    cleantmp
else
	echo "Skipping rust"
fi