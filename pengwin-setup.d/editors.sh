#!/bin/bash

source $(dirname "$0")/common.sh "$@"

declare INSTALLED=false

#Imported from common.h
declare SetupDir

function neovim_install {
  if (confirm --title "NEOVIM" --yesno "Would you like to download and install neovim?" 8 50) ; then
    echo "Installing neovim and building tools from Debian: $ sudo apt-get install neovim build-essential"
    sudo apt-get -y -q -t testing install neovim build-essential

    INSTALLED=true
  else
    echo "Skipping NEOVIM"
  fi
}

function emacs_install {
  if (confirm --title "EMACS" --yesno "Would you like to download and install emacs?" 8 50) ; then
    echo "Installing emacs: $ sudo apt-get install emacs -y"
    sudo apt-get -y -q install emacs

    INSTALLED=true
  else
    echo "Skipping EMACS"
  fi
}

function code_install {
  if (confirm --title "CODE" --yesno "Would you like to download and install Code from Microsoft?" 8 65) ; then
    echo "Installing CODE"
    createtmp
    echo "Downloading and unpacking Microsoft's apt repo key with curl and gpg"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg 
    echo "Moving Microsoft's apt repo key into place with mv"
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg 
    echo "Adding Microsoft apt repo to /etc/apt/sources.list.d/vscode.list with echo"
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' 
    cleantmp

    #Temporary: Fix issue with udev
    echo 'deb https://deb.debian.org/debian stable main' | sudo tee /etc/apt/sources.list.d/stable.list
    sudo apt-mark hold udev libudev1
    sudo apt-get update

    #Temporary: Fix issue with udev
    #UPDATE: Now finds latest version of udev and libudev1 specifically from stable repository
    UdevVersion="$(apt-cache madison udev | grep ' stable' | cut -d'|' -f2 | sed 's| ||g')"
    Libudev1Version="$(apt-cache madison libudev1 | grep ' stable' | cut -d'|' -f2 | sed 's| ||g')"
    sudo apt-get install -y -q --allow-downgrades --allow-change-held-packages -t stable udev=$UdevVersion libudev1=$Libudev1Version
    sudo apt-mark hold udev libudev1

    echo "Installing code with dependencies: $ sudo apt-get install -y -q code libxss1 libasound2 libx11-xcb-dev"
    sudo apt-get install -y -q code libxss1 libasound2 libx11-xcb-dev

    #Temporary: Fix issue with Python Extention of VSCode
    #Assuming that the stable repository is there by the udev fix
    sudo apt-get install -y -q  -t stable libssl1.0.2

    INSTALLED=true
  else
    echo "Skipping CODE"
  fi
}

function editor_menu {
  local editor_choice=$(

    menu --title "Editor Menu" --checklist --separate-output "Custom editors (nano and vi included)\n[SPACE to select, ENTER to confirm]:" 12 55 3 \
      "NEOVIM" "Neovim" off \
      "EMACS" "Emacs" off \
      "CODE" "Visual Studio Code (requires X)   " off \

  3>&1 1>&2 2>&3)

  if [[ ${editor_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${editor_choice} == *"NEOVIM"* ]] ; then
    neovim_install
  fi

  if [[ ${editor_choice} == *"EMACS"* ]] ; then
    emacs_install
  fi

  if [[ ${editor_choice} == *"CODE"* ]] ; then
    code_install
  fi

  if [[ "${INSTALLED}" == true ]] ; then
    bash ${SetupDir}/shortcut.sh --yes "$@"
  fi
}


editor_menu "$@"
