#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

local brew_conf="/etc/profile.d/brew.sh"

echo "Uninstalling Homebrew"

if ! ruby --version; then
	echo "Installing Ruby for uninstall script"
	sudo apt-get install ruby -y -q
fi

echo "Running Homebrew uninstall script"
if ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)" ; then
	echo "Successfully executed script"
else
	if ! brew ; then
		echo "Full uninstall failed. Removing remnants"
		sudo rm -rf "/home/linuxbrew"
		sudo rm -rf "$HOME/.linuxbrew"
	else
		echo "Uninstall failed"
	fi
fi

echo "Removing PATH modification: $brew_conf"
if [[ -f "$brew_conf" ]] ; then
	sudo rm -f "$brew_conf"
else
	echo "... not found!"
fi

}

if show_warning "Homebrew" "Homebrew" "$@" ; then
	main "$@"
fi
