#!/bin/bash

source "/usr/local/wlinux-setup.d/common.sh"

if (whiptail --title "OpenJDK" --yesno "Would you like to Install OpenJDK 8?" 8 42) then
    echo "$ apt install openjdk-8-jre openjdk-8-jdk -y"
    updateupgrade
    sudo apt install openjdk-8-jre openjdk-8-jdk -y
else
    echo "Skipping OpenJDK"
fi
