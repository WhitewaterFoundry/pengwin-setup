#!/bin/bash

source $(dirname "$0")/common.sh "$@"

DOCKERVERSION="18.09.2"
DOCKERCOMPOSEVERSION="1.23.2"

function dockerinstall_build_relay {
    #Build the relay
    if [[ ! -f "${wHome}/.npiperelay/npiperelay.exe" ]]; then

        echo "Checking for go"
        if ! (go version); then
            echo "Downloading Go using wget."
            wget -c "https://dl.google.com/go/go${GOVERSION}.linux-$(dpkg --print-architecture).tar.gz"
            tar -xzf go*.tar.gz

            export GOROOT=$(pwd)/go
            export PATH="${GOROOT}/bin:$PATH"
        fi

        mkdir gohome
        export GOPATH=$(pwd)/gohome

        echo "Checking for git"
        if (git version); then
            git_exists=1
        else
            git_exists=0

            sudo apt-get install -yq git
        fi

        echo "Building npiperelay.exe."
        go get -d github.com/jstarks/npiperelay

        if [[ ${git_exists} -eq 0 ]]; then
            sudo apt-get purge -yq git
            sudo apt-get autoremove -yq
        fi

        GOOS=windows go build -o npiperelay.exe github.com/jstarks/npiperelay
        sudo mkdir -p "${wHome}/.npiperelay"
        cmd.exe /c 'attrib +h %HOMEDRIVE%%HOMEPATH%\.npiperelay'
        sudo cp npiperelay.exe "${wHome}/.npiperelay/npiperelay.exe"
    fi

    sudo apt-get -y -q install socat

    cat << 'EOF' >> docker-relay
#!/bin/bash

connected=$(docker version 2>&1 | grep -c "daemon\|error")
if [[ ${connected} != 0  ]]; then

    PATH=${PATH}:$(wslpath "C:\Windows\System32")
    wHomeWinPath=$(cmd.exe /c 'echo %HOMEDRIVE%%HOMEPATH%' 2>&1 | tr -d '\r')
    wHome=$(wslpath -u "${wHomeWinPath}")

    killall --quiet socat
    exec nohup socat UNIX-LISTEN:/var/run/docker.sock,fork,group=docker,umask=007 EXEC:"\'${wHome}/.npiperelay/npiperelay.exe\' -ep -s //./pipe/docker_engine",nofork  </dev/null &>/dev/null &
fi
EOF
    sudo cp docker-relay /usr/bin/docker-relay
    sudo chmod u+x /usr/bin/docker-relay

    echo '%sudo   ALL=NOPASSWD: /usr/bin/docker-relay' | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/docker-relay

    cat << 'EOF' >> docker_relay.sh
sudo docker-relay
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

function dockerinstall_conf_tcp {
    echo "Connect to Docker via TCP"

    cat << 'EOF' >> docker_relay.sh
export DOCKER_HOST=tcp://0.0.0.0:2375
EOF
    sudo cp docker_relay.sh /etc/profile.d/docker_relay.sh

    export DOCKER_HOST=tcp://0.0.0.0:2375
    connected=$(docker version 2>&1 | grep -c "Cannot connect to the Docker daemon")
    if [[ ${connected} != 0  ]]; then
        whiptail --title "DOCKER" \
        --msgbox "Please go to Docker for Windows -> Settings -> General and enable 'Expose daemon on tcp://localhost:2375 without TLS' or upgrade your Windows version and run this script again." 9 75
    fi
}

if (whiptail --title "DOCKER" --yesno "Would you like to install the bridge to Docker?" 8 55); then
    echo "Installing the bridge to Docker."

    connected=$(docker.exe version 2>&1 | grep -c "docker daemon is not running.\|docker.exe: command not found")
    while [[ ${connected} != 0  ]]; do
        if ! (whiptail --title "DOCKER" --yesno "Docker Desktop appears not to be running, please check it and ensure that it is running correctly. Would you like to try again?" 9 75); then
            return

        fi

        connected=$(docker.exe version 2>&1 | grep -c "docker daemon is not running.\|docker.exe: command not found")

    done

    createtmp
    sudo apt-get update -yq 

    export PATH=${PATH}:$(wslpath "C:\Windows\System32") #Be sure we can execute Windows commands

    wget -c https://download.docker.com/linux/static/stable/$(uname -m)/docker-${DOCKERVERSION}.tgz
    sudo tar -xzvf docker-${DOCKERVERSION}.tgz --overwrite --directory /usr/bin/ --strip-components 1 docker/docker

    sudo chmod 755 /usr/bin/docker
    sudo chown root:root /usr/bin/docker

    #Checks if the Windows 10 version supports Unix Sockets and that the tcp port without TLS is not already open
    connected=$(env DOCKER_HOST=tcp://0.0.0.0:2375 docker version 2>&1 | grep -c "Cannot connect to the Docker daemon")
    if [[ $(reg.exe query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" 2>&1 | egrep -o '([0-9]{5})' | cut -d ' ' -f 2) -gt 17063 && ${connected} != 0  ]]; then
        #Connect via Unix Sockets
        dockerinstall_build_relay
    else
        #Connect via TCP
        dockerinstall_conf_tcp
    fi

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion
    sudo sh -c 'curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker > /etc/bash_completion.d/docker'

    echo "Installing docker-compose"
    sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${DOCKERCOMPOSEVERSION}/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose"
    sudo chmod +x /usr/bin/docker-compose

    sudo sh -c 'curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose'

    docker-compose version

    if [[ $(wslpath 'C:\\') = '/mnt/c/' ]]; then

        if (whiptail --title "DOCKER" --yesno "To correctly integrate the volume mounting between docker Linux and Windows, your root mount point must be changed from /mnt/c to /c. Continue?" 10 80); then
            echo "Changing the root from /mnt to /"

            if [[ $(grep -c "root" /etc/wsl.conf) -eq 0 ]]; then
                sudo sed -i 's$\[automount\]$\0\nroot=/$' /etc/wsl.conf

            else
                sudo sed -i 's$\(root=\)\(.*\)$\1/$' /etc/wsl.conf
            fi

            cat << 'EOF' >> create-mnt-c-link
#!/bin/bash

if [[ -z $(ls -A /mnt/c) ]]; then

    rm -d /mnt/c #Ensure that we only delete the directory if it is empty
    ln -s $(wslpath -u "C:\\") /mnt/c
fi
EOF
            sudo cp create-mnt-c-link /usr/bin/create-mnt-c-link
            sudo chmod u+x /usr/bin/create-mnt-c-link

            echo '%sudo   ALL=NOPASSWD: /usr/bin/create-mnt-c-link' | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/create-mnt-c-link

            cat << 'EOF' >> create-mnt-c-link.sh
sudo create-mnt-c-link
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
