#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

local nim_conf="/etc/profile.d/nim.sh"
rem_dir "$HOME/.choosenim"
rem_dir "$HOME/.nimble"
sudo_rem_file "/etc/profile.d/nim.sh"

}

if show_warning "nim" "$@" ; then
	main "$@"
fi
