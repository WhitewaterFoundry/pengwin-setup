#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

ruby_dir="$HOME/.rbenv"

function main()
{

local ruby_conf="/etc/profile.d/rbenv.sh"

echo "Uninstalling rbenv"

echo "Removing $ruby_dir"
if [[ -d "$ruby_dir" ]] ; then
	rm -rf "$ruby_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier: $ruby_conf"
if [[ -f "$ruby_conf" ]] ; then
	sudo rm -f "$ruby_conf"
else
	echo "... not found!"
fi

}

if show_warning "rbenv" "$ruby_dir" "$@" ; then
	main "$@"
fi
