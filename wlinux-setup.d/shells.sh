#!/bin/bash

source common.sh

function zshinstall {
ZSH_SETUP=".zsh_wlinux"

# Backup old zshrc if existent (e.g. wlinux-setup being re-run)
if [ -f "/etc/zsh/zshrc" ] ; then
    if [ -f "/etc/zsh/"$ZSH_SETUP ] ; then
        echo "wlinux-setup has already modified zshrc"
        echo "run 'sudo rm /etc/zsh/$ZSH_INSTALLED && wlinux-setup' to re-create config file"
    else
        echo "Old zshrc found & not edited before --> backing up"
                 
        # Get current date-time
        dt=$(date '+%d%m%Y-%H%M')
        # Save backup with date-time
        sudo cp /etc/zsh/zshrc /etc/zsh/zshrc_$dt.old
        # Delete old  zshrc so we can start fresh
        sudo rm /etc/zsh/zshrc

        # Need to "unsetopt no_match" to stop line31 in /etc/profile failing on not finding anything under /etc/profile.d/*
        # Reset after to prevent any unforeseen consequences.
        # ALTERNATIVE: "shopt -s failglob" in /etc/profile fixes bash to act more like zsh (we're currently doing reverse)
        # This would prevent issues in other shell alternatives if they appear.
        echo "Creating fresh zshrc and modifying to source /etc/profile"
        sudo touch /etc/zsh/zshrc
        echo "unsetopt no_match" | sudo tee -a /etc/zsh/zshrc
        echo "source /etc/profile" | sudo tee -a /etc/zsh/zshrc
        echo "setopt no_match" | sudo tee -a /etc/zsh/zshrc
        # Create .zsh_wlinux file to let future runs know zshrc has been modified by wlinux-setup
        sudo touch /etc/zsh/$ZSH_SETUP
    fi
fi

if (whiptail --title "zsh" --yesno "Would you like to download and install oh-my-zsh? This is a framework for managing your zsh installation" 8 95) then
    createtmp
    whiptail --title "zsh" --msgbox "After oh-my-zsh is installed and launched, type 'exit' and ENTER to return to wlinux-setup" 8 95
    mkdir "Type exit to return to wlinux-setup" 
    cd "Type exit to return to wlinux-setup" 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    cd ..
    cleantmp
else
    echo "Skipping oh-my-zsh"
fi

if (whiptail --title "zsh" --yesno "Would you like to set zsh as the default shell?" 8 55) then
    chsh -s $(which zsh)
fi
}

function fishinstall {
if (whiptail --title "fish" --yesno "Would you like to download and install oh-my-fish?" 8 55) then
    createtmp
    whiptail --title "fish" --msgbox "After oh my fish is installed and launched, type 'exit' and ENTER to return to wlinux-setup" 8 95
    mkdir "Type exit to return to wlinux-setup" 
    cd "Type exit to return to wlinux-setup" 
    curl -L https://get.oh-my.fish | fish
    cd ..
    cleantmp
else
    echo "Skipping Oh My Fish"
fi

if (whiptail --title "fish" --yesno "Would you like to set fish as the default shell?" 8 55) then
    chsh -s $(which fish)
fi
}

function cshinstall {
if (whiptail --title "csh" --yesno "Would you like to set csh as the default shell?" 8 55) then
    chsh -s $(which csh)
fi
}

EDITORCHOICE=$(
whiptail --title "Shell Menu" --checklist --separate-output "Custom shells (bash included)\n[SPACE to select, ENTER to confirm]:" 12 55 3 \
    "ZSH" "zsh" off \
    "FISH" "fish" off \
    "CSH" "csh" off 3>&1 1>&2 2>&3
)

if [[ $EDITORCHOICE == *"ZSH"* ]] ; then
    echo "Installing zsh..."
    sudo apt install zsh -y
    zshinstall
fi

if [[ $EDITORCHOICE == *"FISH"* ]] ; then
    echo "Installing fish..."
    sudo apt install fish -y
    fishinstall
fi

if [[ $EDITORCHOICE == *"CSH"* ]] ; then
    echo "Installing csh..."
    sudo apt install csh -y
    cshinstall
fi
