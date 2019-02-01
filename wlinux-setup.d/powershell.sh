#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "POWERSHELL" --yesno "Would you like to download and install Powershe$
    echo "Installing POWERSHELL"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    rm microsoft.gpg
    sudo sh -c 'echo "deb https://packages.microsoft.com/repos/microsoft-debian-stretch-pr$
    updateupgrade
    sudo apt -t unstable install liblttng-ust0 libssl1.0.2 libicu57 liburcu6 liblttng-ust-$
    sudo apt install powershell -y
else
    echo "Skipping POWERSHELL"
fi