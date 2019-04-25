#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "PYTHON" --yesno "Would you like to download and install pyenv with Python 3.7?" 7 90) then
    echo "Installing PYENV"
    createtmp

    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    wget https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer
    bash pyenv-installer

    echo "inserting default scripts"
    
    if [ -f ${HOME}/.bashrc ]; then
     	echo "export PATH=\"${HOME}/.pyenv/bin:\$PATH\"" >> ${HOME}/.bashrc
      	echo "eval \"\$(pyenv init -)\"" >> ${HOME}/.bashrc
      	echo "eval \"\$(pyenv virtualenv-init -)\"" >> ${HOME}/.bashrc
	source ${HOME}/.bashrc
    fi

    if [ -f ${HOME}/.zshrc ]; then
    	echo "export PATH=\"${HOME}/.pyenv/bin:\$PATH\"" >> ${HOME}/.zshrc
      	echo "eval \"\$(pyenv init -)\"" >> ${HOME}/.zshrc
      	echo "eval \"\$(pyenv virtualenv-init -)\"" >> ${HOME}/.zshrc
	source ${HOME}/.zshrc
    fi

    if [ -d ${HOME}/.config/fish ]; then
	echo "set -x PATH \"${HOME}/.pyenv/bin\" \$PATH" >> ${HOME}/.config/fish/config.fish
      	echo 'status --is-interactive; and . (pyenv init -|psub)'  >> ${HOME}/.config/fish/config.fish
      	echo 'status --is-interactive; and . (pyenv virtualenv-init -|psub)' >> ${HOME}/.config/fish/config.fish
	source ${HOME}/.config/fish/config.fish	
    fi

    echo "installing Python 3.7"
    pyenv install 3.7.3
    pyenv global 3.7.3

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
