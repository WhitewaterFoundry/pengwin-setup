#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "POWERSHELL" --yesno "Would you like to download and install Powershell?" 8 55); then
  echo "Installing POWERSHELL"

  createtmp

  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
  sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

  sudo sh -c 'echo "deb https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

  update_packages
  install_packages powershell

  cleantmp
else
  echo "Skipping POWERSHELL"
fi
