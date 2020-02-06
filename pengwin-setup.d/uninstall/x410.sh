#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{
    echo "Removing PATH modifier..."
    sudo_rem_file "/etc/profile.d/02-x410.sh"
}

if show_warning "x410" "$@" ; then
	main "$@"
fi
