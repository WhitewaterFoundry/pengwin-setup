#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

shortcut_path=$(wslpath "$(wslvar -l Programs)")/Pengwin\ Applications

function main()
{

echo "Uninstalling Pengwin start-menu shortcuts"
rem_dir "$shortcut_path"

}

if show_warning "Pengwin start-menu shortcuts" "$@" ; then
	main "$@"
fi
