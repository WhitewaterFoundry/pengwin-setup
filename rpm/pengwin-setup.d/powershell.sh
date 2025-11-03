#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# shellcheck disable=SC2155
declare dist="$(uname -m)"
if [[ ${dist} != "x86_64" ]]; then
  message --title "POWERSHELL" --msgbox "PowerShell installation is only supported on x86_64 architecture. Microsoft repositories do not provide PowerShell packages for other architectures." 10 70
  echo "Skipping POWERSHELL - not supported on non-x86_64 architecture"
  exit 1
fi
unset dist

if (confirm --title "POWERSHELL" --yesno "Would you like to download and install Powershell?" 8 55); then
  echo "Installing POWERSHELL"

  createtmp

  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
  sudo cp microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

  sudo sh -c 'echo "deb https://packages.microsoft.com/repos/microsoft-debian-buster-prod buster main" > /etc/apt/sources.list.d/microsoft.list'

  update_packages
  install_packages powershell

  cleantmp
else
  echo "Skipping POWERSHELL"
fi
