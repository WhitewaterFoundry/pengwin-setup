#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "PYTHON" --yesno "Would you like to download and install pyenv with Python 3.7?" 7 90) then
    echo "Installing PYENV"
    createtmp

    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    wget https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer
    bash pyenv-installer

    echo "Installing Bash completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion

    wget https://raw.githubusercontent.com/pyenv/pyenv/master/completions/pyenv.bash
    sudo cp pyenv.bash /etc/bash_completion.d/pyenv_completions.bash

    cleantmp

elif (whiptail --title "PYTHON" --yesno "Would you like to download and install Python 3.7, IDLE, and the pip package manager?" 8 90) then
    echo "Installing PYTHON"
    createtmp
    sudo apt-get -t testing install build-essential python3.7 python3.7-distutils idle-python3.7 python3-pip python3-venv -y
    pip3 install -U pip
    cleantmp
else
    echo "Skipping PYTHON"
fi
