#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (confirm --title "Java" --yesno "Would you like to Install SDKMan to manage and install Java SDKs?" 8 52); then

  sudo apt-get install -y -q zip curl
  echo "$ curl -s "https://get.sdkman.io" | bash"

  curl -s "https://get.sdkman.io" | bash

  source "${HOME}/.sdkman/bin/sdkman-init.sh"

  sdk version

  curl https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/sdkman.completion.bash | sudo tee /etc/bash_completion.d/sdkman.bash

  whiptail --title "SDKMan" --msgbox "Please close and re-open Pengwin.\n\nTo install Java use: \n\nsdk list java\n\nThen: \n\nsdk install java 'version'" 15 60

else
  echo "Skipping Java"
fi
