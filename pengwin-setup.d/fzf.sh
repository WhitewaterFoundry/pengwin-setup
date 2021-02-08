#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (whiptail --title "FZF" --yesno "Would you like to download and install command line finder fzf?" 8 80) then
    echo "Installing FZF"
    cd ~
    git clone --depth 1 https://github.com/junegunn/fzf.git
    cd fzf
    ./install
else
    echo "Skipping FZF"
fi
