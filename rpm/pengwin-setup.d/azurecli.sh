#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "AZURECLI" --yesno "Would you like to download and install Azure command line tools?" 8 70); then
  echo "Installing AZURECLI"
  createtmp
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
  sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
  sudo chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg
  sudo bash -c "echo 'deb https://packages.microsoft.com/repos/azure-cli/ buster main' > /etc/apt/sources.list.d/azurecli.list"
  sudo apt-get -y -q update

  install_packages -t buster azure-cli jq
  cleantmp
else
  echo "Skipping AZURECLI"
fi
