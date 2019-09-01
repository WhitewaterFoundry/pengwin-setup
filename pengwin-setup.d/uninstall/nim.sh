#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

local nim_conf="/etc/profile.d/nim.sh"

echo "Uninstalling nim"

echo "Removing ~/.choosenim/"
rem_dir "$HOME/.choosenim"

echo "Removing ~/.nimble/"
rem_dir "$HOME/.nimble"

echo "Removing PATH modifier..."
sudo_rem_file "/etc/profile.d/nim.sh"

}

if show_warning "nim" "$@" ; then
	main "$@"
fi
