#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "NODE" --yesno "Would you like to download and install NodeJS using n and the npm package manager?" 8 88) then
    echo "Installing NODE"

    echo "Installing n, Node.js version manager"
    curl -L https://git.io/n-install -o n-install.sh | export N_PREFIX="${HOME}/.n" bash

    echo "Ensuring we have build-essential installed"
    sudo apt install build-essential -y

    echo "Installing latest node.js release"
    n latest

    echo "Installing npm"
    curl -0 -L https://npmjs.com/install.sh | sh

        if (whiptail --title "YARN" --yesno "Would you like to download and install the Yarn package manager? (optional)" 8 80) then
            echo "Installing YARN"
            curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt-get update && sudo apt-get install yarn --no-install-recommends
        else
            echo "Skipping YARN"
        fi
else
    echo "Skipping NODE"
fi
