#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling base GUI libraries and modifications"

remove_package "xclip" "gnome-themes-standard" "gtk2-engines-murrine" "dbus-x11"

echo "Removing dbus configuration files..."
sudo_rem_file "/etc/dbus-1/session.conf"
sudo_rem_file "/usr/share/dbus-1/session.conf"

}

if show_warning "" "" ; then
	main "$@"
fi
