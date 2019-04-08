#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (confirm --title "Java" --yesno "Would you like to Install SDKMan to manage and install Java SDKs?" 8 52); then

  sudo apt-get install -y -q zip curl
  echo "$ curl -s "https://get.sdkman.io" | bash"

  curl -s "https://get.sdkman.io" | bash

  source "${HOME}/.sdkman/bin/sdkman-init.sh"

  sdk version

  whiptail --title "SDKMan" --msgbox "Please close and re-open Pengwin.\n\nTo install Java use: sdk list java to see the available versions. Then sdk install java 'version'" 12 60
else
  echo "Skipping Java"
fi
