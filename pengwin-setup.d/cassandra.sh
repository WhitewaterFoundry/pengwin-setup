#!/bin/bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"
declare wHome
declare wHomeWinPath
declare USER

function main() {

  if (confirm --title "CASSANDRA" --yesno "Would you like to download and install Apache Cassandra?" 8 60); then

    echo "Installing CASSANDRA"
    createtmp
    curl https://dist.apache.org/repos/dist/release/cassandra/KEYS | gpg --dearmor > cassandra.gpg
    sudo cp cassandra.gpg /etc/apt/trusted.gpg.d/cassandra.gpg
    sudo chmod 644 /etc/apt/trusted.gpg.d/cassandra.gpg
    sudo bash -c "echo 'deb http://www.apache.org/dist/cassandra/debian 311x main' > /etc/apt/sources.list.d/cassandra.list"
    sudo apt-get -y -q update

    local mountProc="/usr/bin/mount-proc"
    sudo tee "${mountProc}" << EOF
#!/bin/bash

mount -t proc proc /proc

EOF

    sudo chmod 700 "${mountProc}"

    echo "%sudo   ALL=NOPASSWD: ${mountProc}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/mount-proc

    local startCassandra="/usr/bin/start-cassandra"
    sudo tee "${startCassandra}" << EOF
#!/bin/bash

sudo -Su cassandra /usr/sbin/cassandra -f

EOF

    sudo chmod 700 "${startCassandra}"

    echo "%sudo   ALL=NOPASSWD: ${startCassandra}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/start-cassandra

    local profile_mountproc="/etc/profile.d/mount-proc.sh"
    sudo tee "${profile_mountproc}" << 'EOF'
#!/bin/sh

if [ "$(df /proc | grep proc | cut -c47-51)" != "/proc" ]; then
  sudo /usr/bin/mount-proc
fi

EOF

    sudo chmod 700 "${profile_mountproc}"

    sudo "${mountProc}"
    sudo apt-get -y -q install cassandra

    whiptail --title "CASSANDRA" --msgbox "Cassandra must be run as user cassandra, $ sudo -u cassandra /usr/sbin/cassandra -f " 8 90

    if (whiptail --title "CASSANDRA" --yesno "Would you like to store Cassandra configuration and logs in your Windows user home folder?" 8 95) ; then

      if [[ -d "${wHome}/cassandra" ]]; then
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

    if (whiptail --title "CASSANDRA" --yesno "Would you like to create .bat files to run Cassandra in your Windows user home folder?" 8 102) ; then

      sudo mkdir "${wHome}/cassandra/" # in case user opted to keep config on WSL

      echo "Creating autorun.bat file in home folder"
      local phrase1='pengwin.exe run " '
      local phrase2=" sudo ${mountProc}"
      local phrase3=" sudo ${startCassandra}"
      local write1="${phrase1}${phrase2}"
      local write2="${phrase1}${phrase3}"
      cat << EOF > autorun.bat
@echo off
${write1}"
${write2}"
EOF
      sudo cp autorun.bat "${wHome}/cassandra/"

      echo "Creating installservice.bat file on Windows Desktop"
      phrase1='sc create NewService binpath= '
      phrase2='\cassandra\autorun.bat type= share start= auto displayname= Cassandra'
      write="$phrase1${wHomeWinPath}$phrase2"
      sudo cat << EOF > installservice.bat
@echo off
${write}
EOF
      sudo cp installservice.bat "${wHome}/cassandra/"

    fi

    cleantmp
  else
    echo "Skipping CASSANDRA"
  fi

}

main
