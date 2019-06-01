#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

# We need to delete everything between 2 instances of this string
PENGWIN_STRING='### PENGWIN OPTIMISED DEFAULTS'

function main()
{

echo "Uninstalling inputrc bash-shell optimisations"

echo "Cleaning /etc/inputrc"
if [[ -f "/etc/inputrc" ]] ; then
	sudo_inclusive_file_clean "/etc/inputrc" "$PENGWIN_STRING"
else
	echo "... not found!"
fi

}

if show_warning "" "" ; then
	main "$@"
fi
