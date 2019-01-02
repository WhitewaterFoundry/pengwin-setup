#!/bin/bash

source "/etc/wlinux-setup.d/common.sh"

if (whiptail --title "DOTNET" --yesno "Would you like to download and install the .NET Core SDK for Linux?" 8 75) then
    echo "Installing DOTNET"
    createtmp
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    rm microsoft.gpg
    sudo sh -c 'echo "deb https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list' 
    updateupgrade
    sudo apt install dotnet-sdk-2.1 -y
    cleantmp

    if (whiptail --title "NUGET" --yesno "Would you like to download and install NuGet?" 8 50) then
        echo "Installing NuGet"
        sudo apt install nuget -y
    else
        echo "Skipping NUGET"
    fi

else
    echo "Skipping DOTNET"
fi
