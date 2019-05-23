#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

colortool_dir="$wHome/.ColorTool"

function main()
{

local colortool_conf="/etc/profile.d/01-colortool.sh"
local colortool_script="/usr/local/bin/colortool"

echo "Uninstalling ColorTool"

echo "Removing $colortool_dir"
if [[ -d "$colortool_dir" ]] ; then
	rm -rf "$colortool_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier: $colortool_conf"
if [[ -f "$colortool_conf" ]] ; then
	sudo rm -f "$colortool_conf"
else
	echo "... not found!"
fi

echo "Removing $colortool_script script"
if [[ -f "$colortool_script" ]] ; then
	sudo rm -f "$colortool_script"
else
	echo "... not found!"
fi

}

if show_warning "ColorTool" "$colortool_dir" "$@" ; then
	main "$@"
fi
