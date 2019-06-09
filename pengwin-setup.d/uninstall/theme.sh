#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Windows 10 themes"

rem_file "$HOME/.gtkrc-2.0"
sudo_rem_dir "/usr/share/themes/windows-10-dark"
sudo_rem_dir "/usr/share/themes/windows-10-light"

remove_package "lxappearance"

echo "Regenerating start-menu entry cache..."
bash ${SetupDir}/shortcut.sh --yes

}

if show_warning "Windows 10 GTK/Qt themes" "$@" ; then
	main "$@"
fi
