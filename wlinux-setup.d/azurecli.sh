#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "AZURECLI" --yesno "Would you like to download and install Azure command line tools?" 8 70) then
    echo "Installing AZURECLI"
    createtmp
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    sudo chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg
    sudo bash -c "echo 'deb https://packages.microsoft.com/repos/azure-cli/ stretch main' >> /etc/apt/sources.list.d/azurecli.list"
    sudo apt-get update
    echo "Note: azure-cli install can appear to 'stall' at 16%, it is usually not broken, just taking a long time."
    sudo apt-get install azure-cli -y
    cleantmp
else
    echo "Skipping AZURECLI"
fi
