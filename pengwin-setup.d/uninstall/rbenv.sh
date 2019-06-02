#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

local ruby_conf="/etc/profile.d/rbenv.sh"

echo "Uninstalling rbenv"

rem_dir "$HOME/.rbenv"

echo "Removing PATH modifier..."
sudo_rem_file "/etc/profile.d/rbenv.sh"

}

if show_warning "rbenv" "$@" ; then
	main "$@"
fi
