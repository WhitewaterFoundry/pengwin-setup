#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

function install_jetbrains_support() {

  install_packages rsync zip

  if [[ "${1}" == "--no-toolbox" ]]; then
    return
  fi

  if (confirm --title "JetBrains Toolbox support" --yesno "Would you like to install JetBrains Toolbox to run inside WSL?${REQUIRES_X}" 10 52); then
    install_packages \
      fuse libfuse2 \
      libxi6 libxrender1 libxtst6 libfontconfig1 \
      tar dbus-user-session at-spi2-core binfmt-support \
      dconf-gsettings-backend dconf-service \
      glib-networking glib-networking-common glib-networking-services \
      gsettings-desktop-schemas libarchive13 \
      libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
      libcolord2 libdconf1 libepoxy0 libevdev2 \
      libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 \
      libinput-bin libinput10 \
      libjson-glib-1.0-0 libjson-glib-1.0-common \
      liblzo2-2 libmd4c0 libmtdev1 libproxy1v5 \
      libqt5dbus5 libqt5gui5 libqt5network5 libqt5svg5 libqt5widgets5 \
      libsoup-gnome2.4-1 libsoup2.4-1 libsquashfuse0 \
      libwacom-bin libwacom-common \
      libwayland-cursor0 libwayland-egl1 \
      libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
      libxcb-render-util0 libxcb-util1 libxcb-xinerama0 libxcb-xinput0 libxcb-xkb1 \
      libxcursor1 libxdamage1 libxkbcommon-x11-0 libxkbcommon0 \
      qt5-gtk-platformtheme xkb-data
    curl -fsSL https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash

    message --title "JetBrains Toolbox support" --msgbox "You can run JetBrains Toolbox from\n\n~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox" 10 52

    echo -e "You can run JetBrains Toolbox from\n\n~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox\n"
  fi
}

if (confirm --title "JetBrains support" --yesno "Would you like to install support to JetBrains tools?" 8 52); then
  install_jetbrains_support ""
else
  echo "Skipping Jetbrains support"
fi
