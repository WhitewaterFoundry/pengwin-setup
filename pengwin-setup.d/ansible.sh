#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

if (whiptail --title "ANSIBLE" --yesno "Would you like to download and install Ansible?" 8 55); then
  echo "Installing ANSIBLE"
  sudo debconf-apt-progress -- apt-get -y install ansible
else
  echo "Skipping ANSIBLE"
fi
