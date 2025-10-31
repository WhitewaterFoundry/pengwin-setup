#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

function install_jetbrains_support() {

  install_packages rsync zip

  if [[ "${1}" == "--no-toolbox" ]]; then
    return
  fi

  if (confirm --title "JetBrains Toolbox support" --yesno "Would you like to install JetBrains Toolbox to run inside WSL?${REQUIRES_X}" 10 52); then
    install_packages libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig1 libgtk-3-bin tar dbus-user-session
    curl -fsSL https://raw.githubusercontent.com/WhitewaterFoundry/jetbrains-toolbox-install/refs/heads/master/jetbrains-toolbox.sh | bash

    message --title "JetBrains Toolbox support" --msgbox "You can run JetBrains Toolbox from\n\n~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox" 10 52

    echo -e "You can run JetBrains Toolbox from\n\n~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox\n"
  fi
}

if (confirm --title "JetBrains support" --yesno "Would you like to install support to JetBrains tools?" 8 52); then
  install_jetbrains_support ""
else
  echo "Skipping Jetbrains support"
fi
