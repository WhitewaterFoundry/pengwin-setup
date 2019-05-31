#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Qt and GTK HiDPI modifications"
sudo_rem_file "/etc/profile.d/hidpi.sh"

}

if show_warning "" "" ; then
	main "$@"
fi
