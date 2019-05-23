#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

vcxsrv_dir="$wHome/.vcxsrv"

function main()
{

local vcxsrv_conf="/etc/profile.d/vcxsrv.sh"

echo "Uninstalling VcxSrv"

echo "Stopping vcxsrv.exe"
if cmd-exe /C tasklist | grep -Fq 'vcxsrv.exe' ; then
	cmd-exe /C taskkill /IM 'vcxsrv.exe' /F
else
	echo "vcxsrv.exe not running"
fi

echo "Removing $vcxsrv_dir"
if [[ -d "$vcxsrv_dir" ]] ; then
	rm -rf "$vcxsrv_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier: $vcxsrv_conf"
if [[ -f "$vcxsrv_conf" ]] ; then
	sudo rm -f "$vcxsrv_conf"
else
	echo "... not found!"
fi

}

if show_warning "vcxsrv" "$vcxsrv_dir" "$@" ; then
	main "$@"
fi
