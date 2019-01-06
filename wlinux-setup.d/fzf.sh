#!/bin/bash

source "/usr/local/wlinux-setup.d/common.sh"

if (whiptail --title "FZF" --yesno "Would you like to download and install command line finder fzf?" 8 80) then
    echo "Installing FZF"
    cd ~
    git clone --depth 1 https://github.com/junegunn/fzf.git
    cd fzf
    ./install
else
    echo "Skipping FZF"
fi
