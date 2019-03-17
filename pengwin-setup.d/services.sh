#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function enable_rclocal() {


  if (confirm --title "rc.local" --yesno "Would you like to enable rc.local support for running scripts at Pengwin launch?" 10 60) ; then
    echo "Enabling rc.local..."

    echo '%sudo   ALL=NOPASSWD: /bin/bash /etc/rc.local' | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/rclocal
    echo 'sudo /bin/bash /etc/rc.local' | sudo tee /etc/profile.d/rclocal.sh

    sudo mkdir /etc/boot.d

  else
    echo "Skipping rc.local"
  fi

}

function main() {

  MENU_CHOICE=""

  menu --title "Services Menu" --checklist --separate-output "Enables service support\n[SPACE to select, ENTER to confirm]:" 10 70 2 \
    "RCLOCAL" "Enable running scripts at startup from rc.local " off \
    "SSH" "Enable SSH server" off

  if [[ ${MENU_CHOICE} == *"RCLOCAL"* ]] ; then

      enable_rclocal "$@"
  fi
}

main "$@"