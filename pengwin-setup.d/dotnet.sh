#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

# shellcheck disable=SC2155
dist="$(uname -m)"
if [[ ${dist} != "x86_64" ]] && [[ ${dist} != "aarch64" ]]; then
  message --title "DOTNET" --msgbox ".NET SDK 10 installation is only supported on x86_64 and ARM64 (aarch64) architectures. Microsoft repositories do not provide .NET SDK 10 packages for other architectures." 10 80
  echo "Skipping DOTNET - not supported on ${dist} architecture"
  exit 1
fi
unset dist

if (confirm --title "DOTNET" --yesno "Would you like to download and install the .NET SDK for Linux?" 8 75) ; then
  echo "Installing DOTNET"
  createtmp
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

  echo 'deb https://packages.microsoft.com/repos/microsoft-debian-bookworm-prod bookworm main' | sudo tee /etc/apt/sources.list.d/microsoft.list

  update_packages

  install_packages dotnet-sdk-10.0
  cleantmp

  if (confirm --title "NUGET" --yesno "Would you like to download and install NuGet?" 8 50) ; then
    echo "Installing NuGet"
    install_packages nuget
  else
    echo "Skipping NUGET"
  fi

else
  echo "Skipping DOTNET"
fi
