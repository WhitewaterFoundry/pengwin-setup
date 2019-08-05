#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling base GUI libraries and modifications"

echo "Removing dbus configuration files..."
sudo_rem_file "/etc/dbus-1/session.conf"
sudo_rem_file "/usr/share/dbus-1/session.conf"

remove_package "xclip" "gnome-themes-standard" "gtk2-engines-murrine" "dbus-x11"

}

if show_warning "base GUI libraries and modifications" "$@" ; then
	main "$@"
fi
