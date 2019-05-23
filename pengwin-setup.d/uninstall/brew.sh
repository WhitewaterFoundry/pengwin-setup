#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

local brew_conf="/etc/profile.d/brew.sh"

echo "Uninstalling Homebrew"

echo "Running Homebrew uninstall script"
if ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)" ; then
	echo "Successfully executed script"
else
	echo "Uninstall failed"
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
