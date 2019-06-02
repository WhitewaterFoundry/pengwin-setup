#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Powershell"

remove_package "powershell"

echo "Removing APT source(s)..."
sudo_rem_file "/etc/apt/sources.list.d/microsoft.list"
sudo_rem_file "/etc/apt/sources.list.d/stable.list"

echo "Removing APT key..."
sudo_rem_file "/etc/apt/trusted.gpg.d/microsoft.gpg"

}

if show_warning "Powershell" "$@" ; then
	main "$@"
fi
