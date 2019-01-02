#!/bin/bash

source common.sh

if (whiptail --title "PYTHON" --yesno "Would you like to download and install Python 3.7, IDLE, and the pip package manager?" 8 90) then
    echo "Installing PYTHON"
    createtmp
    updateupgrade
    sudo apt -t testing install build-essential python3.7 python3.7-distutils idle-python3.7 python3-pip python3-venv -y
    pip3 install -U pip
    cleantmp
else
    echo "Skipping PYTHON"
fi
