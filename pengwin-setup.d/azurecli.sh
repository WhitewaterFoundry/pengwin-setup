#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "AZURECLI" --yesno "Would you like to download and install Azure command line tools?" 8 70); then
  echo "Installing AZURECLI"

  install_packages ca-certificates curl apt-transport-https lsb-release gnupg
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

  sudo chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg

  sudo bash -c "echo 'deb https://packages.microsoft.com/repos/azure-cli/ bookworm main' > /etc/apt/sources.list.d/azurecli.list"

  update_packages
  install_packages -t bookworm azure-cli
else
  echo "Skipping AZURECLI"
fi
