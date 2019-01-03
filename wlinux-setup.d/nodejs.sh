#!/bin/bash

source "common.sh" "$@"

if (whiptail --title "NODE" --yesno "Would you like to download and install NodeJS using n and the npm package manager?" 8 88) then
    echo "Installing NODE"
    createtmp
    updateupgrade
    sudo apt install n build-essential -y 
    sudo n latest
    curl -0 -L https://npmjs.com/install.sh | sudo sh
    cleantmp

        if (whiptail --title "YARN" --yesno "Would you like to download and install the Yarn package manager? (optional)" 8 80) then
            echo "Installing YARN"
            createtmp
            curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt-get update && sudo apt-get install yarn --no-install-recommends
            cleantmp
        else
            echo "Skipping YARN"
        fi
else
    echo "Skipping NODE"
fi
