#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling dotnet"

remove_package "dotnet-sdk-2.2" "nuget"

echo "Removing APT source(s)..."
safe_rem_microsoftsrc
safe_rem_debianstablesrc

echo "Removing APT key..."
safe_rem_microsoftgpg

}

if show_warning "dotnet" "$@" ; then
	main "$@"
fi
