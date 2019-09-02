#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "NIM" --yesno "Would you like to download and install nim using choosenim?" 8 63) then
    createtmp
    echo "Installing choosenim dependencies."
    sudo apt-get -y install xz-utils gcc

    echo "Downloading and running choosenim."
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh
    
    echo "Setting environment variables and adding to PATH."
    export NIMPATH=$HOME/.nimble/bin
    export PATH=$NIMPATH:$PATH

    echo "Saving environment variables to /etc/profile so they will persist."
    sudo sh -c 'echo "export NIMPATH=\${HOME}/.nimble/bin" >> /etc/profile.d/nim.sh'
    sudo sh -c 'echo "export PATH=\$NIMPATH:\$PATH" >> /etc/profile.d/nim.sh'

    source /etc/profile.d/nim.sh
    cleantmp
else
    echo "Skipping GO"
fi
