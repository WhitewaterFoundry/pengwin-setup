#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

vcxsrv_dir="$wHome/.vcxsrv"

function main()
{

local vcxsrv_conf="/etc/profile.d/vcxsrv.sh"

echo "Uninstalling VcxSrv"

echo "Removing $vcxsrv_dir"
if [[ -d "$vcxsrv_dir" ]] ; then
	if cmd-exe "/C tasklist" | grep -Fq 'vcxsrv.exe' ; then
		echo "vcxsrv.exe running. Killing process..."
		cmd-exe "/C taskkill /IM 'vcxsrv.exe' /F"
	fi

	# now safe to delete
	rm -rf "$vcxsrv_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier..."
sudo_rem_file "/etc/profile.d/vcxsrv.sh"

}

if show_warning "vcxsrv" "$@" ; then
	main "$@"
fi
