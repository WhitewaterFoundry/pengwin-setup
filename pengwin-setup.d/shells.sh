#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

function zshinstall() {
  ZSH_SETUP=".zsh_pengwin"

  # Backup old zshrc if existent (e.g. pengwin-setup being re-run)
  if [ -f "/etc/zsh/zshrc" ]; then

    if [ -f "/etc/zsh/"$ZSH_SETUP ]; then
      echo "pengwin-setup has already modified zshrc"
      echo "run 'sudo rm /etc/zsh/$ZSH_INSTALLED && pengwin-setup' to re-create config file"
    else
      if [ -f "/etc/zsh/zprofile" ]; then
        echo "Old zprofile found --> backing up"

        # Get current date-time
        dt="$(date '+%d%m%Y-%H%M')"

        # Save backup with date-time
        sudo cp /etc/zsh/zprofile "/etc/zsh/zprofile_${dt}.old"
        echo "Old zshrc backed up to /etc/zsh/zprofile_${dt}.old"

        # Delete old zprofile so we can start fresh
        sudo rm /etc/zsh/zprofile
      fi

      # Need to "unsetopt no_match" to stop line31 in /etc/profile failing on not finding anything under /etc/profile.d/*
      # Reset after to prevent any unforeseen consequences.
      # ALTERNATIVE: "shopt -s failglob" in /etc/profile fixes bash to act more like zsh (we're currently doing reverse)
      # This would prevent issues in other shell alternatives if they appear.

      echo "Creating fresh zshrc, modifying to add pengwin template commands and source /etc/profile"
      if [[ ! -d "/etc/zsh" ]]; then
        echo "/etc/zsh not found, creating..."
        sudo mkdir -p /etc/zsh
      fi

      sudo touch /etc/zsh/zprofile
      sudo tee -a /etc/zsh/zprofile <<EOF
unsetopt no_match
source /etc/profile
setopt no_match
EOF

      # Create .zsh_pengwin file to let future runs know zshrc has been modified by pengwin-setup
      sudo touch /etc/zsh/$ZSH_SETUP
    fi
  fi

  if (whiptail --title "zsh" --yesno "Would you like to download and install oh-my-zsh? This is a framework for managing your zsh installation" 8 95); then
    createtmp
    whiptail --title "zsh" --msgbox "After oh-my-zsh is installed and launched, type 'exit' and ENTER to return to pengwin-setup" 8 95
    mkdir "Type exit to return to pengwin-setup"
    cd "Type exit to return to pengwin-setup"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    cd ..

    #Change the default theme for one more friendly with Windows console default font
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' "${HOME}/.zshrc"

    cleantmp
  else
    echo "Skipping oh-my-zsh"
  fi

  if (whiptail --title "zsh" --yesno "Would you like to set zsh as the default shell?" 8 55); then
    chsh -s "$(which zsh)"
  fi
}

function fish_install() {
  createtmp
  sudo apt install fish python -y # /usr/bin/python required for omf

  whiptail --title "fish" --msgbox "After oh my fish is installed and launched, type 'exit' and ENTER to return to pengwin-setup" 8 95

  mkdir "Type exit to return to pengwin-setup"
  cd "Type exit to return to pengwin-setup"

  curl -L https://get.oh-my.fish | fish
  cd ..

  # Change the default theme for one more friendly with Windows console default font
  fish -c "omf install bira"

  # Install bash compatibility plugin
  fish -c "omf install bass"

  cleantmp

  if (confirm --title "fish" --yesno "Would you like to set fish as the default shell?" 8 55); then
    chsh -s "$(which fish)"
  fi
}

function cshinstall() {
  if (whiptail --title "csh" --yesno "Would you like to set csh as the default shell?" 8 55); then
    chsh -s "$(which csh)"
  fi
}

function installandsetshell() {
  local menu_choice=$(

    menu --title "Shell Menu" --checklist --separate-output "Custom shells and improvements (bash included)\n[SPACE to select, ENTER to confirm]:" 12 80 4 \
      "ZSH" "zsh" off \
      "FISH" "fish with oh-my-fish plugin manager" off \
      "CSH" "csh" off \
      "BASH-RL" "Recommended readline settings for productivity " off

  3>&1 1>&2 2>&3)

  echo "Selected:" ${menu_choice}

  if [[ $menu_choice == *"ZSH"* ]]; then
    echo "Installing zsh..."
    sudo apt install zsh -y
    zshinstall
  fi

  if [[ $menu_choice == *"FISH"* ]]; then
    echo "Installing fish..."
    fish_install
  fi

  if [[ $menu_choice == *"CSH"* ]]; then
    echo "Installing csh..."
    sudo apt install csh -y
    cshinstall
  fi

  if [[ $menu_choice == *"BASH-RL"* ]]; then
    echo "BASH-RL"
    bash "${SetupDir}"/shell-opts.sh "$@"
  fi

}

installandsetshell "$@"
