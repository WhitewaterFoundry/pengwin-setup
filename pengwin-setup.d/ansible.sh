#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

if (whiptail --title "ANSIBLE" --yesno "Would you like to download and install Ansible?" 8 55); then
  echo "Installing ANSIBLE"
  install_packages ansible
else
  echo "Skipping ANSIBLE"
fi
