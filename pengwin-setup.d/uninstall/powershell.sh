#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Powershell"

remove_package "powershell"

echo "Removing APT source(s)..."
safe_rem_microsoftsrc
safe_rem_debianstablesrc

echo "Removing APT key..."
safe_rem_microsoftgpg

}

if show_warning "Powershell" "$@" ; then
	main "$@"
fi
