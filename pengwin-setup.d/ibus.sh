#!/bin/bash
# bashsupport disable=SpellCheckingInspection

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "ibus" --yesno "Would you like to install ibus for improved non-Latin input via iBus?" 8 65); then
  echo "Installing ibus"

  install_packages ibus ibus-gtk ibus-gtk3 fonts-noto-cjk fonts-noto-color-emoji dbus-x11 zenity -y
  install_packages ibus-gtk4 -y >/dev/null 2>&1

  FCCHOICE=$(
    menu --title "iBus engines" --checklist --separate-output "Select iBus engine:" 17 65 10 \
      "sunpinyin" "Chinese sunpinyin" off \
      "libpinyin" "Chinese libpinyin" off \
      "pinyin" "Chinese pinyin" off \
      "rime" "Chinese rime" off \
      "chewing" "Chinese chewing" off \
      "mozc" "Japanese mozc" off \
      "kkc" "Japanese kkc" off \
      "hangul" "Korean hangul" off \
      "unikey" "Vietnamese unikey" off \
      "table" "Tables (Includes all available tables)  " off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ $FCCHOICE == *"sunpinyin"* ]]; then
    install_packages ibus-sunpinyin
  fi

  if [[ $FCCHOICE == *"libpinyin"* ]]; then
    install_packages ibus-libpinyin
  fi

  if [[ $FCCHOICE == *"rime"* ]]; then
    install_packages ibus-rime
  fi

  if [[ $FCCHOICE == *"pinyin"* ]]; then
    install_packages ibus-pinyin
  fi

  if [[ $FCCHOICE == *"chewing"* ]]; then
    install_packages ibus-chewing
  fi

  if [[ $FCCHOICE == *"mozc"* ]]; then
    install_packages ibus-mozc mozc-utils-gui
  fi

  if [[ $FCCHOICE == *"kkc"* ]]; then
    install_packages ibus-kkc
  fi

  if [[ $FCCHOICE == *"hangul"* ]]; then
    install_packages ibus-hangul
  fi

  if [[ $FCCHOICE == *"unikey"* ]]; then
    install_packages ibus-unikey
  fi

  if [[ $FCCHOICE == *"tables"* ]]; then
    install_packages ibus-table '^ibus-table-*'
  fi

  echo "Setting environmental variables"
  export XIM=ibus
  export XIM_PROGRAM=/usr/bin/ibus
  export QT_IM_MODULE=ibus
  export GTK_IM_MODULE=ibus
  export XMODIFIERS=@im=ibus
  export DefaultIMModule=ibus

  echo "Saving environmental variables to /etc/profile.d/ibus.sh"
  sudo sh -c 'echo "export XIM=ibus" > /etc/profile.d/ibus.sh'
  sudo sh -c 'echo "export XIM_PROGRAM=/usr/bin/ibus" >> /etc/profile.d/ibus.sh'
  sudo sh -c 'echo "export QT_IM_MODULE=ibus" >> /etc/profile.d/ibus.sh'
  sudo sh -c 'echo "export GTK_IM_MODULE=ibus" >> /etc/profile.d/ibus.sh'
  sudo sh -c 'echo "export XMODIFIERS=@im=ibus" >> /etc/profile.d/ibus.sh'
  sudo sh -c 'echo "export DefaultIMModule=ibus" >> /etc/profile.d/ibus.sh'

  if (confirm --title "ibus daemon" --yesno "Would you like Setup iBus now? WARNING: Requires an X server to be running or WSLg, or it will generate errors." 9 70); then
    echo "Setting up iBus"
    if [[ -z "${NON_INTERACTIVE}" ]]; then
      ibus-daemon -x -d
      ibus-setup
      pkill ibus-daemon
    fi
    ibus-daemon -x -d
  else
    echo "Skipping ibus setup"
    message --title "Note about ibus Setup" --msgbox "You will need to run \n$ ibus-daemon -drx\n$ dbus-launch ibus-setup\n to set up iBus before running GUI apps." 8 85
  fi

  if (confirm --title "ibus daemon" --yesno "Would you like iBus daemon to run each time you open Pengwin? WARNING: Requires an X server to be running or WSLg, or it will generate errors." 9 70); then
    echo "Placing ibus-daemon in /etc/profile.d/ibus.sh"
    sudo sh -c 'echo "ibus-daemon -drx > /dev/null 2>&1" >> /etc/profile.d/ibus.sh'
  else
    echo "Skipping ibus-daemon"
    message --title "Note about ibus-daemon" --msgbox "You will need to run $ ibus-daemon -drx to enable iBus before running GUI apps." 8 85
  fi
else
  echo "Skipping ibus"
fi
