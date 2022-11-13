#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir

function install_jetbrains_support() {

  install_packages rsync zip

  # shellcheck disable=SC2155
  local appdata_path="$(wslpath -u "$(wslvar APPDATA)")"
  local jetbrains_path="${appdata_path}/JetBrains"

  if [[ -d "${jetbrains_path}" ]]; then
    local options_folder_list=${jetbrains_path}/"*/options"

    for options_folder in ${options_folder_list}; do

      if [[ -f "${options_folder}/wsl.distributions.xml" ]]; then
        local reg_exp='\(<microsoft-id>\)Pengwin\(</microsoft-id>\)'

        for line in ${options_folder}/"wsl.distributions.xml"; do
          if (grep -q ${reg_exp} <"${line}"); then
            sed -i "s#${reg_exp}#\1WLinux\2#" "${line}"
          fi
        done
      else
        cp "${SetupDir}/template-wsl.distributions.xml" "${options_folder}/wsl.distributions.xml"
      fi
    done
  fi

  if (confirm --title "JetBrains Toolbox support" --yesno "Would you like to install support for JetBrains Toolbox to run inside WSL?" 10 52); then
    install_packages fuse at-spi2-core binfmt-support dconf-gsettings-backend dconf-service glib-networking glib-networking-common glib-networking-services gsettings-desktop-schemas libappimage0 libarchive13 libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0 libcolord2 libdconf1 libepoxy0 libevdev2 libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libinput-bin libinput10 libjson-glib-1.0-0 libjson-glib-1.0-common liblzo2-2 libmd4c0 libmtdev1 libproxy1v5 libqt5dbus5 libqt5gui5 libqt5network5 libqt5svg5 libqt5widgets5 librest-0.7-0 libsoup-gnome2.4-1 libsoup2.4-1 libsquashfuse0 libwacom-bin libwacom-common libwacom2 libwayland-cursor0 libwayland-egl1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-util1 libxcb-xinerama0 libxcb-xinput0 libxcb-xkb1 libxcursor1 libxdamage1 libxkbcommon-x11-0 libxkbcommon0 qt5-gtk-platformtheme xkb-data
  fi

  install_jetbrains_support
}

if (confirm --title "JetBrains support" --yesno "Would you like to install support to JetBrains tools?" 8 52); then
  install_jetbrains_support
else
  echo "Skipping Jetbrains support"
fi
