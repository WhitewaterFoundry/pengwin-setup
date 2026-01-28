#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (confirm --title "DOTNET" --yesno "Would you like to download and install the .NET SDK for Linux?" 8 75) ; then
  echo "Installing DOTNET"
  createtmp
  
  wget https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb

  update_packages

  install_packages dotnet-sdk-10.0
  cleantmp

else
  echo "Skipping DOTNET"
fi
