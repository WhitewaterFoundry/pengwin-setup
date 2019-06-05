#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling dotnet"

remove_package "dotnet-sdk-2.2"

echo "Removing APT source..."
sudo_rem_file "/etc/apt/sources.list.d/microsoft.list"

echo "Removing APT key..."
sudo_rem_file "/etc/apt/trusted.gpg.d/microsoft.gpg"

}

if show_warning "dotnet" "$@" ; then
	main "$@"
fi
