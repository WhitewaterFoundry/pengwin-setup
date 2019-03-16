#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "CASSANDRA" --yesno "Would you like to download and install Apache Cassandra?" 8 60) then
    echo "Installing CASSANDRA"
    createtmp
    curl https://dist.apache.org/repos/dist/release/cassandra/KEYS | gpg --dearmor > cassandra.gpg
    sudo cp cassandra.gpg /etc/apt/trusted.gpg.d/cassandra.gpg
    sudo chmod 644 /etc/apt/trusted.gpg.d/cassandra.gpg
    sudo bash -c "echo 'deb http://www.apache.org/dist/cassandra/debian 311x main' > /etc/apt/sources.list.d/cassandra.list"
    sudo apt-get update
    sudo su -c "echo '${USER} ALL=(root) NOPASSWD: /bin/mount, /bin/umount' >> /etc/sudoers"
    sudo mount -t proc proc /proc
    sudo apt-get install cassandra -y
    sudo su -c "echo 'cassandra ALL=(root) NOPASSWD: /bin/mount, /bin/umount' >> /etc/sudoers"
    sudo su -c "echo 'sudo mount -t proc proc /proc' >> /etc/profile"

    whiptail --title "CASSANDRA" --msgbox "Cassandra must be run as user cassandra, $ sudo -u cassandra /usr/sbin/cassandra -f " 8 90

    if (whiptail --title "CASSANDRA" --yesno "Would you like to store Cassandra configuration and logs in your Windows user home folder?" 8 95) then

        if [ -d "${wHome}/cassandra" ]; then
            echo "Backing up existing Cassandra directony"
            sudo cp -r "${wHome}/cassandra" "${wHome}/cassandra.old"
        fi

        echo "Moving Cassandra configuration directory"
        sudo unlink /etc/cassandra # these clean up from previous installs
        sudo mkdir /etc/cassandra
        sudo cp -r /etc/cassandra/ "${wHome}"
        sudo rm -r /etc/cassandra
        sudo ln -s "${wHome}/cassandra" /etc/cassandra

        echo "Moving Cassandra log directory"
        sudo mkdir "${wHome}/cassandra/logs"
        sudo rm -r /var/log/cassandra
        sudo ln -s "${wHome}/cassandra/logs" /var/log/cassandra

        echo "Setting permissions"
        sudo chown -R cassandra:cassandra /etc/cassandra
        sudo chown -R cassandra:cassandra /var/lib/cassandra/
        sudo chown -R cassandra:cassandra /var/log/cassandra/
    fi

    if (whiptail --title "CASSANDRA" --yesno "Would you like to create .bat files to run and update Cassandra in your Windows user home folder?" 8 102) then

        echo "Enter your UNIX password below."
        passvar=0
        read -s -p "[sudo] password for $USER: " passvar
        until (echo $sudo_pwd | sudo -S echo '' 2>/dev/null)
        do
            echo -e '\nSorry, try again.'
            read -s -p "[sudo] password for $USER: " passvar
        done

        sudo mkdir "${wHome}/cassandra/" # in case user opted to keep config on WSL

        echo "Creating autorun.bat file in home folder"
        phrase1='wlinux.exe run "echo '
        phrase2=" | sudo -Su root mount -t proc proc /proc"
        phrase3=" | sudo -Su cassandra /usr/sbin/cassandra -f"
        write1="$phrase1$passvar$phrase2"
        write2="$phrase1$passvar$phrase3"
        cat << EOF > autorun.bat
@echo off
$write1"
$write2"
EOF
        sudo cp autorun.bat "${wHome}/cassandra/"

        echo "Creating update.bat file on Windows Desktop"
        phrase1='wlinux.exe run "echo '
        phrase2=' | sudo -S apt-get update ; sudo -S apt-get upgrade -y ; sudo -S apt-get autoclean -y"'
        write="$phrase1$passvar$phrase2"
        sudo cat << EOF > update.bat
@echo off
$write
EOF
        sudo cp update.bat "${wHome}/cassandra/"

        echo "Creating installservice .bat file on Windows Desktop"
        phrase1='sc create NewService binpath= '
        phrase2='/cassandra/autorun.bat type= share start= auto displayname= Cassandra'
        write="$phrase1${wHome}$phrase2"
        sudo cat << EOF > installservice.bat
@echo off
$write
EOF
        sudo cp installservice.bat "${wHome}/cassandra/"

    fi

    cleantmp
else
    echo "Skipping CASSANDRA"
fi
