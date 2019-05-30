#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling rust"

rem_dir "$HOME/.rustup"
rem_dir "$HOME/.cargo"

echo "Removing PATH modifier(s)..."
sudo_rem_file "/etc/profile.d/rust.sh"
sudo_rem_file "/etc/fish/conf.d/rust.sh"

}

if show_warning "rust" "$rustup_dir and $cargo_dir" "$@" ; then
	main "$@"
fi
