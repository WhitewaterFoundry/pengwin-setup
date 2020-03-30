#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

DOCKER_VERSION="19.03.4"
DOCKER_COMPOSE_VERSION="1.24.1"

# Imported from common.sh
declare wHome
declare GOVERSION

#Imported global variables
declare USER

function docker_install_build_relay() {
  #Build the relay
  if [[ ! -f "${wHome}/.npiperelay/npiperelay.exe" ]]; then

    echo "Checking for go"
    command_check '/usr/local/go/bin/go' 'version'
    local go_check=$?
    if [ $go_check -eq 1 ] ; then
      echo "Downloading Go using wget."
      wget -c "https://dl.google.com/go/go${GOVERSION}.linux-$(dpkg --print-architecture).tar.gz"
      tar -xzf go*.tar.gz

      export GOROOT=$(pwd)/go
      export PATH="${GOROOT}/bin:$PATH"
    else
      if [ $go_check -eq 2 ] ; then
        # If go was only just installed previously without shell reset,
        # makes sure to set correct env variables
        export GOROOT=/usr/local/go
        export PATH="${GOROOT}/bin:$PATH"
      fi
    fi

    mkdir gohome
    export GOPATH=$(pwd)/gohome

    echo "Checking for git"
    local git_exists
    if (git version); then
      git_exists=1
    else
      git_exists=0

      sudo apt-get -y -q install git
    fi

    echo "Building npiperelay.exe."
    go get -d github.com/jstarks/npiperelay

    if [[ ${git_exists} -eq 0 ]]; then
      sudo apt-get -y -q purge git
      sudo apt-get -y -q autoremove
    fi

    GOOS=windows go build -o npiperelay.exe github.com/jstarks/npiperelay
    sudo mkdir -p "${wHome}/.npiperelay"
    cmd-exe /c 'attrib +h %HOMEDRIVE%%HOMEPATH%\.npiperelay'
    sudo cp npiperelay.exe "${wHome}/.npiperelay/npiperelay.exe"
  fi

  sudo apt-get -y -q install socat

  cat << 'EOF' >> docker-relay
#!/bin/bash

#Import the Windows path
PATH="$1"

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then

  connected=$(docker version 2>&1 | grep -c "daemon\|error")
  if [[ ${connected} != 0  ]]; then

    wHomeWinPath=$(cmd-exe /c 'echo %HOMEDRIVE%%HOMEPATH%' | tr -d '\r')
    wHome=$(wslpath -u "${wHomeWinPath}")

    killall --quiet socat
    exec nohup socat UNIX-LISTEN:/var/run/docker.sock,fork,group=docker,umask=007 EXEC:"\'${wHome}/.npiperelay/npiperelay.exe\' -ep -s //./pipe/docker_engine",nofork  </dev/null &>/dev/null &
  fi
fi

EOF

  sudo cp docker-relay /usr/bin/docker-relay
  sudo chmod u+x /usr/bin/docker-relay

  echo '%sudo   ALL=NOPASSWD: /usr/bin/docker-relay' | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/docker-relay

  cat << 'EOF' >> docker_relay.sh

if [ -z "${WSL2}" ]; then

  # Check if we have Windows Path
  if ( which cmd.exe >/dev/null ); then
    sudo docker-relay "${PATH}"
  fi
fi
EOF

  sudo cp docker_relay.sh /etc/profile.d/docker_relay.sh
  sudo chmod -w /usr/bin/docker-relay

  sudo addgroup docker
  sudo adduser ${USER} docker

  echo "Running the relay for the first time."
  sudo docker-relay

  sleep 1s

  sudo docker version
}

function docker_install_conf_tcp() {
  echo "Connect to Docker via TCP"

  cat << 'EOF' >> docker_relay.sh
# Only the default WSL user should run this script
if ! (id -Gn | grep -c "adm.*sudo\|sudo.*adm" >/dev/null); then
  return
fi

if [ -z "${WSL2}" ]; then
  export DOCKER_HOST=tcp://0.0.0.0:2375
fi

EOF
  sudo cp docker_relay.sh /etc/profile.d/docker_relay.sh

  export DOCKER_HOST=tcp://0.0.0.0:2375
  connected=$(docker version 2>&1 | grep -c "Cannot connect to the Docker daemon")
  if [[ ${connected} != 0  ]]; then
    whiptail --title "DOCKER" \
    --msgbox "Please go to Docker Desktop -> Settings -> General and enable 'Expose daemon on tcp://localhost:2375 without TLS' or upgrade your Windows version and run this script again." 9 75
  else
    docker version
  fi
}

function docker_install_conf_toolbox() {
  echo "Connect to Docker Toolbox"

  cat << 'EOF' >> docker_relay.sh

if [ -z "${WSL2}" ]; then
  # Check if we have Windows Path
  if ( which cmd.exe >/dev/null ); then
    VM=${DOCKER_MACHINE_NAME-default}
    DOCKER_MACHINE="$(which docker-machine.exe)"
    eval "$("${DOCKER_MACHINE}" env --shell=bash --no-proxy "${VM}" 2>/dev/null )" > /dev/null 2>&1

    if [[ "${DOCKER_CERT_PATH}" != "" ]] ; then
      export DOCKER_CERT_PATH="$(wslpath -u "${DOCKER_CERT_PATH}")"
    fi
  fi
fi
EOF
  sudo cp docker_relay.sh /etc/profile.d/docker_relay.sh

  . /etc/profile.d/docker_relay.sh

  docker version
}

function main() {
  if [[ -n ${WSL2} ]]; then
    whiptail --title "DOCKER" --msgbox "Docker integration is not supported yet in WSL 2" 8 60
    return
  fi

  if (confirm --title "DOCKER" --yesno "Would you like to install the bridge to Docker?" 8 55); then
    echo "Installing the bridge to Docker."

    local errorCheck="docker daemon is not running.\|docker.exe: command not found\|error during connect:"
    local connected
    connected=$(docker.exe version 2>&1 | grep -c "${errorCheck}")
    while [[ ${connected} != 0  ]]; do
      if ! (whiptail --title "DOCKER" --yesno "Docker Desktop or Docker Toolbox appears not to be running, please check it and ensure that it is running correctly. Would you like to try again?" 9 75); then
        return

      fi

      connected=$(docker.exe version 2>&1 | grep -c "${errorCheck}")

    done

    createtmp

    sudo apt-get -y -q update

    wget -c "https://download.docker.com/linux/static/stable/$(uname -m)/docker-${DOCKER_VERSION}.tgz"
    sudo tar -xzvf docker-${DOCKER_VERSION}.tgz --overwrite --directory /usr/bin/ --strip-components 1 docker/docker

    sudo chmod 755 /usr/bin/docker
    sudo chown root:root /usr/bin/docker

    #Checks if the Windows 10 version supports Unix Sockets and that the tcp port without TLS is not already open
    connected=$(env DOCKER_HOST=tcp://0.0.0.0:2375 docker version 2>&1 | grep -c "Cannot connect to the Docker daemon")
    local currentVersion=$(reg.exe query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" 2>&1 | egrep -o '([0-9]{5})' | cut -d ' ' -f 2)

    if [[ $(docker-machine.exe active | grep -c "default") != 0 && ${connected} != 0 ]]; then
      #Install via Docker Toolbox
      docker_install_conf_toolbox
    elif [[ ${currentVersion} -gt 17063 && ${connected} != 0  ]]; then
      #Connect via Unix Sockets
      docker_install_build_relay
    else
      #Connect via TCP
      docker_install_conf_tcp
    fi

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get -y -q install bash-completion
    sudo sh -c 'curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker > /etc/bash_completion.d/docker'

    echo "Installing docker-compose"
    sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose"
    sudo chmod +x /usr/bin/docker-compose

    sudo sh -c 'curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose'

    docker-compose version

    if [[ ${currentVersion} -gt 17063 && $(wslpath 'C:\') = '/mnt/c/' ]]; then

      if (whiptail --title "DOCKER" --yesno "To correctly integrate the volume mounting between docker Linux and Windows, your root mount point must be changed from /mnt/c to /c. Continue?" 10 80); then
        echo "Changing the root from /mnt to /"

        if [[ $(grep -c "root" /etc/wsl.conf) -eq 0 ]]; then
          sudo sed -i 's$\[automount\]$\0\nroot=/$' /etc/wsl.conf

        else
          sudo sed -i 's$\(root=\)\(.*\)$\1/$' /etc/wsl.conf
        fi

        cat << 'EOF' >> create-mnt-c-link
#!/bin/bash

for l in $( ls /mnt ); do
  if [[ ${#l} -gt 1 ]]; then
    continue
  fi

  DEST_PATH=$(wslpath -u "${l^^}:\\" 2>/dev/null)

  if [[ $? != 0 ]]; then
    continue
  fi

  if [[ -z $(ls -A /mnt/${l} 2>/dev/null) ]]; then

    if [[ $? != 0 ]]; then
      continue
    fi

    rm -d /mnt/${l} 2>/dev/null #Ensure that we only delete the directory if it is empty
    ln -s $DEST_PATH /mnt/${l} 2>/dev/null
  fi

done

EOF
        sudo cp create-mnt-c-link /usr/bin/create-mnt-c-link
        sudo chmod u+x /usr/bin/create-mnt-c-link

        echo '%sudo   ALL=NOPASSWD: /usr/bin/create-mnt-c-link' | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/create-mnt-c-link

        cat << 'EOF' >> create-mnt-c-link.sh

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then
  sudo create-mnt-c-link
fi

EOF
        sudo cp create-mnt-c-link.sh /etc/profile.d/create-mnt-c-link.sh
        sudo chmod -w /usr/bin/create-mnt-c-link
      fi


    fi

    whiptail --title "DOCKER" --msgbox "Docker bridge is ready. Please close and re-open Pengwin" 8 60
    cleantmp

  else
    echo "Skipping Docker"
  fi
}

main

