#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

local go_conf="/etc/profile.d/go.sh"

echo "Uninstalling go"

echo "Removing $go_dir"
sudo_rem_dir "/usr/local/go"

echo "Removing PATH modifier..."
sudo_rem_file "/etc/profile.d/go.sh"

# whiptail user go directory

}

if show_warning "go" "$go_dir" "$@" ; then
	main "$@"
fi
