#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (confirm --title "fcitx" --yesno "Would you like to install fcitx for improved non-Latin input?" 8 65); then
  echo "Installing fcitx"
  echo "sudo apt-get install fcitx fonts-noto-cjk fonts-noto-color-emoji dbus-x11 -y"
  install_packages fcitx fonts-noto-cjk fonts-noto-color-emoji dbus-x11
  FCCHOICE=$(
    menu --title "fcitx engines" --separate-output --checklist "Select fcitx engine:" 18 65 11 \
      "sunpinyin" "Chinese sunpinyin" off \
      "libpinyin" "Chinese libpinyin" off \
      "rime" "Chinese rime" off \
      "googlepinyin" "Chinese googlepinyin" off \
      "chewing" "Chinese chewing" off \
      "mozc" "Japanese mozc" off \
      "kkc" "Japanese kkc" off \
      "hangul" "Korean hangul" off \
      "unikey" "Vietnamese unikey" off \
      "sayura" "Sinhalese sayura" off \
      "table" "Tables (Includes all available tables)" off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ $FCCHOICE == *"sunpinyin"* ]]; then
    install_packages fcitx-sunpinyin -y
  fi

  if [[ $FCCHOICE == *"libpinyin"* ]]; then
    install_packages fcitx-libpinyin -y
  fi

  if [[ $FCCHOICE == *"rime"* ]]; then
    install_packages fcitx-rime -y
  fi

  if [[ $FCCHOICE == *"googlepinyin"* ]]; then
    install_packages fcitx-googlepinyin -y
  fi

  if [[ $FCCHOICE == *"chewing"* ]]; then
    install_packages fcitx-chewing -y
  fi

  if [[ $FCCHOICE == *"mozc"* ]]; then
    install_packages fcitx-mozc -y
  fi

  if [[ $FCCHOICE == *"kkc"* ]]; then
    install_packages fcitx-kkc fcitx-kkc-dev -y
  fi

  if [[ $FCCHOICE == *"hangul"* ]]; then
    install_packages fcitx-hangul -y
  fi

  if [[ $FCCHOICE == *"unikey"* ]]; then
    install_packages fcitx-unikey -y
  fi

  if [[ $FCCHOICE == *"sayura"* ]]; then
    install_packages fcitx-sayura -y
  fi

  if [[ $FCCHOICE == *"tables"* ]]; then
    install_packages fcitx-table fcitx-table-all -y
  fi

  echo "Setting environmental variables"
  export GTK_IM_MODULE=fcitx
  export QT_IM_MODULE=fcitx
  export XMODIFIERS=@im=fcitx
  export DefaultIMModule=fcitx

  echo "Saving environmental variables to /etc/profile.d/fcitx.sh"
  sudo sh -c 'echo "#!/bin/bash" >> /etc/profile.d/fcitx.sh'
  sudo sh -c 'echo "export QT_IM_MODULE=fcitx" >> /etc/profile.d/fcitx.sh'
  sudo sh -c 'echo "export GTK_IM_MODULE=fcitx" >> /etc/profile.d/fcitx.sh'
  sudo sh -c 'echo "export XMODIFIERS=@im=fcitx" >> /etc/profile.d/fcitx.sh'
  sudo sh -c 'echo "export DefaultIMModule=fcitx" >> /etc/profile.d/fcitx.sh'

  if (confirm --title "fcitx-autostart" --yesno "Would you like fcitx-autostart to run each time you open Pengwin? WARNING: Requires an X server / WSLg to be running, or it will generate errors." 9 70); then
    echo "Placing fcitx-autostart in /etc/profile.d/fcitx"
    sudo sh -c 'echo "/usr/bin/fcitx-autostart > /dev/null 2>&1" >> /etc/profile.d/fcitx.sh'
  else
    echo "Skipping fcitx-autostart"
    message --title "Note about fcitx-autostart" --msgbox "You will need to run $ fcitx-autostart to enable fcitx before running GUI apps." 8 85
  fi

  echo "Configuring dbus machine id"
  sudo sh -c "dbus-uuidgen > /var/lib/dbus/machine-id"

  if (confirm --title "fcitx-autostart" --yesno "Would you like to run fcitx-autostart now? Requires an X server / WSLg to be running." 8 85); then
    echo "Starting fcitx-autostart"
    dbus-launch /usr/bin/fcitx-autostart >/dev/null 2>&1
  else
    echo "Skipping start fcitx-autostart"
  fi

  if (confirm --title "fcitx-config-gtk3" --yesno "Would you like to configure fcitx now? Requires an X server / WSLg to be running." 8 80); then
    echo "Running fcitx-config-gtk3"
    fcitx-config-gtk3
  else
    echo "Skipping fcitx-config-gtk3"
  fi

  message --title "Note about fcitx-config-gtk3" --msgbox "You can configure fcitx later by running $ fcitx-config-gtk3" 8 70
else
  echo "Skipping fcitx"
fi
