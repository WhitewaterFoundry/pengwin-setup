#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function neovim_install {
  if (whiptail --title "NEOVIM" --yesno "Would you like to download and install neovim?" 8 50) ; then
    echo "Installing neovim and building tools from Debian: $ sudo apt install neovim build-essential"
    updateupgrade
    sudo apt-get -y -q -t testing install neovim build-essential
  else
    echo "Skipping NEOVIM"
  fi
}

function emacs_install {
  if (whiptail --title "EMACS" --yesno "Would you like to download and install emacs?" 8 50) ; then
    echo "Installing emacs: $ sudo apt install emacs -y"
    updateupgrade
    sudo apt-get -y -q install emacs
  else
    echo "Skipping EMACS"
  fi
}

function code_install {
  if (whiptail --title "CODE" --yesno "Would you like to download and install Code from Microsoft?" 8 65) ; then
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
    echo 'deb https://deb.debian.org/debian stretch-backports main' | sudo tee /etc/apt/sources.list.d/stretch-backports.list
    sudo apt-mark hold udev libudev1

    updateupgrade

    #Temporary: Fix issue with udev
    sudo apt-get install -y -q --allow-downgrades --allow-change-held-packages -t stretch-backports udev=239-12~bpo9+1 libudev1=239-12~bpo9+1
    sudo apt-mark hold udev libudev1

    echo "Installing code with dependencies: $ sudo apt-get install -y -q code libxss1 libasound2 libx11-xcb-dev"
    sudo apt-get install -y -q code libxss1 libasound2 libx11-xcb-dev libssl1.0.2

    #Temporary: Fix issue with Python Extention of VSCode
    echo 'deb https://deb.debian.org/debian stable main' | sudo tee /etc/apt/sources.list.d/stable.list
    sudo apt-get update
    sudo apt-get install -y -q libssl1.0.2

  else
    echo "Skipping CODE"
  fi
}

function editor_menu {
  local editor_choice=$(
    whiptail --title "Editor Menu" --checklist --separate-output "Custom editors (nano and vi included)\n[SPACE to select, ENTER to confirm]:" 12 55 3 \
      "NEOVIM" "Neovim" off \
      "EMACS" "Emacs" off \
      "CODE" "Visual Studio Code (requires X)" off 3>&1 1>&2 2>&3
  )

  if [[ ${editor_choice} == *"NEOVIM"* ]] ; then
    neovim_install
  fi

  if [[ ${editor_choice} == *"EMACS"* ]] ; then
    emacs_install
  fi

  if [[ ${editor_choice} == *"CODE"* ]] ; then
    code_install
  fi
}

editor_menu "$@"