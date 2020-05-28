#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (whiptail --title "DOTNET" --yesno "Would you like to download and install the .NET Core SDK for Linux?" 8 75) ; then
  echo "Installing DOTNET"
  createtmp
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

  echo 'deb https://packages.microsoft.com/repos/microsoft-debian-buster-prod buster main' | sudo tee /etc/apt/sources.list.d/microsoft.list
  sudo apt-get update

  sudo debconf-apt-progress -- apt-get -y install dotnet-sdk-3.1
  cleantmp

  if (whiptail --title "NUGET" --yesno "Would you like to download and install NuGet?" 8 50) ; then
    echo "Installing NuGet"
    sudo apt-get -q -y install nuget
  else
    echo "Skipping NUGET"
  fi

else
  echo "Skipping DOTNET"
fi
