#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Homebrew"
local tmp_ruby=1

if ! ruby --version > /dev/null 2>&1 ; then
	echo "Installing Ruby for uninstall script"
	sudo apt-get install ruby -y -q
	tmp_ruby=0
fi

echo "Running Homebrew uninstall script"
whiptail --title "Homebrew" --msgbox "Please type 'y' when requested to by the Homebrew uninstaller" 8 85
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

echo "Removing PATH modification..."
sudo_rem_file "/etc/profile.d/brew.sh"

if [ $tmp_ruby -eq 0 ] ; then
	echo "Ruby temporarily installed for uninstall script, removing..."
	sudo apt-get remove -y -q ruby --autoremove
fi

}

if show_warning "Homebrew" "$@" ; then
	main "$@"
fi
