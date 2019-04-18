#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "PYTHON" --yesno "Would you like to download and install pyenv with Python 3.7?" 7 90) then
    echo "Installing PYENV"
    createtmp

    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    wget https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer
    bash pyenv-installer

    export PATH="${HOME}/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    echo "inserting default scripts"

    case "$shell" in
  	bash )
     	echo "export PATH=\"${HOME}/.pyenv/bin:\$PATH\"" >> ~/.bashrc
      	echo "eval \"\$(pyenv init -)\"" >> ~/.bashrc
      	echo "eval \"\$(pyenv virtualenv-init -)\"" >> ~/.bashrc
   	;;
  	zsh )
    	echo "export PATH=\"${HOME}/.pyenv/bin:\$PATH\"" >> ~/.zshrc
      	echo "eval \"\$(pyenv init -)\"" >> ~/.zshrc
      	echo "eval \"\$(pyenv virtualenv-init -)\"" >> ~/.zshrc
    	;;
  	fish )
	mkdir -p ~/.config/fish
	echo "set -x PATH \"${HOME}/.pyenv/bin\" \$PATH" >> ~/.config/fish/config.fish
      	echo 'status --is-interactive; and . (pyenv init -|psub)'  >> ~/.config/fish/config.fish
      	echo 'status --is-interactive; and . (pyenv virtualenv-init -|psub)' >> ~/.config/fish/config.fish
    	;;
  esac 

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
