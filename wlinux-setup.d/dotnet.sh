#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "DOTNET" --yesno "Would you like to download and install the .NET Core SDK for Linux?" 8 75) ; then
  echo "Installing DOTNET"
  createtmp
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

  echo 'deb https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main' | sudo tee /etc/apt/sources.list.d/microsoft.list
  #Temporary: Fix issue with libssl1.0.2
  echo 'deb https://deb.debian.org/debian stable main' | sudo tee /etc/apt/sources.list.d/stable.list
  sudo apt-get update
  sudo apt-get -y -q install dotnet-sdk-2.1
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
