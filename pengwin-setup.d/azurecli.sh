#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "AZURECLI" --yesno "Would you like to download and install Azure command line tools?" 8 70); then
  echo "Installing AZURECLI"
  
  install_packages ca-certificates curl apt-transport-https lsb-release gnupg
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

  sudo chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg
  
  AZ_REPO=$(lsb_release -cs)
  sudo bash -c "echo 'deb https://packages.microsoft.com/repos/azure-cli/ ${AZ_REPO} main' > /etc/apt/sources.list.d/azurecli.list"
  
  sudo apt-get -y -q update
  install_packages -t bullseye azure-cli
  
  # Remove wslview as the default browser
  wslview -u

else
  echo "Skipping AZURECLI"
fi
