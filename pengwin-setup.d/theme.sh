#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

#Imported from common.h
declare SetupDir

if (confirm --title "Windows 10 Theme" --yesno "Would you like to install a Windows 10 theme? (including lxappearance, a GUI application to set the theme)" 8 70); then
  echo "Installing Windows 10 theme"
  # Source files locations
  W10LIGHT_URL="https://github.com/B00merang-Project/Windows-10/archive/master.zip"
  W10DARK_URL="https://github.com/B00merang-Project/Windows-10-Dark/archive/master.zip"
  W10ICONS_URL="https://github.com/B00merang-Artwork/Windows-10/archive/master.zip"
  INSTALL_DIR="/usr/share/themes"
  INSTALL_ICONS_DIR="/usr/share/icons"
  LIGHT_DIR="windows-10-light"
  DARK_DIR="windows-10-dark"
  ICONS_DIR="windows-10"

  echo "$ sudo apt-get -y -q install unzip dmz-cursor-theme"
  sudo apt-get -y -q install unzip dmz-cursor-theme

  # Download themes to temporary folder (sub folders for light & dark) then unzip
  echo "Downloading themes to temporary folder"
  createtmp

  wget ${W10LIGHT_URL} -O master-light.zip -q --show-progress
  echo "Unzipping master-light.zip..."
  unzip -qq master-light.zip

  wget ${W10DARK_URL} -O master-dark.zip -q --show-progress
  echo "Unzipping master-dark.zip..."
  unzip -qq master-dark.zip

  mkdir icons
  (
    cd icons || exit
    wget ${W10ICONS_URL} -O master-icons.zip -q --show-progress
    echo "Unzipping master-icons.zip..."
    unzip -qq master-icons.zip
  )

  if [[ ! -d "${INSTALL_DIR}" ]]; then
    echo "${INSTALL_DIR} does not exist, creating"
    sudo mkdir -p $INSTALL_DIR
  fi

  if [[ -d "${INSTALL_DIR}/${LIGHT_DIR}" ]]; then
    echo "${INSTALL_DIR}/${LIGHT_DIR} already exists, removing old"
    sudo rm -r $INSTALL_DIR/$LIGHT_DIR
  fi

  if [[ -d "${INSTALL_DIR}/${DARK_DIR}" ]]; then
    echo "${INSTALL_DIR}/${DARK_DIR} already exists, removing old"
    sudo rm -r $INSTALL_DIR/$DARK_DIR
  fi

  if [[ -d "${INSTALL_ICONS_DIR}/${ICONS_DIR}" ]]; then
    echo "${INSTALL_ICONS_DIR}/${ICONS_DIR} already exists, removing old"
    sudo rm -r $INSTALL_ICONS_DIR/$ICONS_DIR
  fi

  # Move to themes folder
  echo "Moving themes to ${INSTALL_DIR}" and "${INSTALL_ICONS_DIR}"
  sudo mv Windows-10-master "${INSTALL_DIR}/${LIGHT_DIR}"
  sudo mv Windows-10-Dark-master "${INSTALL_DIR}/${DARK_DIR}"
  sudo mv icons/Windows-10-master "${INSTALL_ICONS_DIR}/${ICONS_DIR}"

  # Set correct permissions
  echo "Setting correct theme folder permissions"
  sudo chown -R root:root "${INSTALL_DIR}/${LIGHT_DIR}"
  sudo chown -R root:root "${INSTALL_DIR}/${DARK_DIR}"
  sudo chown -R root:root "${INSTALL_ICONS_DIR}/${ICONS_DIR}"
  sudo chmod -R 0755 "${INSTALL_DIR}/${LIGHT_DIR}"
  sudo chmod -R 0755 "${INSTALL_DIR}/${DARK_DIR}"
  sudo chmod -R 0755 "${INSTALL_ICONS_DIR}/${ICONS_DIR}"

  # Install lxappearance to let user set theme
  sudo apt-get install -q -y lxappearance

  lxappearance &

  bash ${SetupDir}/shortcut.sh --yes "$@"

  # Cleanup
  cleantmp
  message --title "Set Windows 10 theme" --msgbox "To set the either of the Windows 10 light/dark themes:\nRun 'lxappearance', choose from the list of installed themes and click apply. You may change the theme in this way at anytime, including fonts, icons and cursors." 9 90
else
  echo "Skipping Windows 10 theme install"
fi
