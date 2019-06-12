#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

gtk_rgx='s|"windows-10.*"|""|g'

function main()
{

echo "Uninstalling Windows 10 themes"

sudo_rem_dir "/usr/share/themes/windows-10-dark"
sudo_rem_dir "/usr/share/themes/windows-10-light"
sudo_rem_dir "/usr/share/icons/windows-10"

if (whiptail --title "LXAppearance" --yesno "LXAppearance was installed alongside the Windows 10 themes to allow setting of Linux GUI application themes. Would you like to remove this too?" 8 85) ; then
	remove_package "lxappearance"

	rem_file "$HOME/.gtkrc-2.0"

	echo "Regenerating start-menu entry cache..."
	bash ${SetupDir}/shortcut.sh --yes
else
	echo "User opted to keep LXAppearance installed. Cleaning Win10 theme configurations"
	sed -i "$HOME/.gtkrc-2.0" -e "$gtk_rgx"
fi

}

if show_warning "Windows 10 GTK/Qt themes" "$@" ; then
	main "$@"
fi
