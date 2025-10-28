#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling JetBrains Toolbox"

  echo "Removing JetBrains Toolbox installation directory"
  rem_dir "$HOME/.local/share/JetBrains/Toolbox"

  echo "Removing JetBrains Toolbox symlink"
  rem_file "$HOME/.local/bin/jetbrains-toolbox"

  echo "Removing JetBrains Toolbox packages"
  remove_package \
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

  echo "Removing base JetBrains support packages"
  remove_package rsync zip

}

if show_warning "JetBrains Toolbox" "$@"; then
  main "$@"
fi
