#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (whiptail --title "GO" --yesno "Would you like to download and install the latest Go from Google?" 8 70) then
    createtmp
    echo "Downloading Go using wget."
    wget https://dl.google.com/go/go${GOVERSION}.linux-$(dpkg --print-architecture).tar.gz
    echo "Unpacking tar binaries to /usr/local/go."
    sudo tar -C /usr/local -xzf go*.tar.gz
    echo "Creating ~/go/ for your projects."
    mkdir ~/go/
    echo "Setting Go environment variables GOROOT, GOPATH, and adding Go to PATH with export."
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go/
    export PATH=$GOPATH/bin:$GOROOT/bin:/usr/local/go/bin:$PATH
    echo "Saving Go environment variables to /etc/profile so they will persist."
    sudo sh -c 'echo "export GOROOT=/usr/local/go" >> /etc/profile.d/go.sh'
    sudo sh -c 'echo "export GOPATH=\${HOME}/go/" >> /etc/profile.d/go.sh'
    sudo sh -c 'echo "export PATH=\${GOPATH}/bin:\${GOROOT}/bin:/usr/local/go/bin:\${PATH}" >> /etc/profile.d/go.sh'
    source /etc/profile.d/go.sh
    cleantmp
else
    echo "Skipping GO"
fi
