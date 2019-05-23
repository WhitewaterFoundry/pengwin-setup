#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

go_dir="/usr/local/go"

function main()
{

local go_conf="/etc/profile.d/go.sh"

echo "Uninstalling go"

echo "Removing $go_dir"
if [[ -d "$go_dir" ]] ; then
	sudo rm -rf "$go_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier: $go_conf"
if [[ -f "$go_conf" ]] ; then
	sudo rm -f "$go_conf"
else
	echo "... not found!"
fi

# whiptail user go directory

}

if show_warning "go" "$go_dir" "$@" ; then
	main "$@"
fi
