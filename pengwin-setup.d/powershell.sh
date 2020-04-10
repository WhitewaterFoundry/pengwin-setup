#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (whiptail --title "POWERSHELL" --yesno "Would you like to download and install Powershell?" 8 55) then
    echo "Installing POWERSHELL"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    rm microsoft.gpg
    sudo sh -c 'echo "deb https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'
    sudo sh -c 'echo "deb https://deb.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list.d/stretch.list'
    sudo apt-get update
    sudo apt-get install powershell -y
else
    echo "Skipping POWERSHELL"
fi
