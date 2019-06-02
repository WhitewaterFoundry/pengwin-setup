#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Windows 10 themes"

# Unset themes ?

remove_package "lxappearance"

sudo_rem_dir "/usr/share/themes/windows-10-dark"
sudo_rem_dir "/usr/share/themes/windows-10-light"

}

if show_warning "Windows 10 GTK/Qt themes" "$@" ; then
	main "$@"
fi
