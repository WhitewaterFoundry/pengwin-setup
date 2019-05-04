#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "ANSIBLE" --yesno "Would you like to download and install Ansible?" 8 55) then
    echo "Installing ANSIBLE"
    gpg --keyserver keyserver.ubuntu.com --recv 93C4A3FD7BB9C367
    gpg --export --armor 93C4A3FD7BB9C367 | sudo apt-key add -
    sudo sh -c 'echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" > /etc/apt/sources.list.d/ansible.list'
    sudo apt-get update
    sudo apt-get -y install ansible
else
    echo "Skipping ANSIBLE"
fi
