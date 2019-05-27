#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

rustup_dir="$HOME/.rustup"
cargo_dir="$HOME/.cargo"

function main()
{

local rust_conf="/etc/profile.d/rust.sh"
local rust_fish_conf="/etc/fish/conf.d/rust.sh"

echo "Uninstalling rust"

echo "Removing $rustup_dir"
if [[ -d "$rustup_dir" ]] ; then
	rm -rf "$rustup_dir"
else
	echo "... not found!"
fi

echo "Removing $cargo_dir"
if [[ -d "$cargo_dir" ]] ; then
	rm -rf "$cargo_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier(s)"
if [[ -f "$rust_conf" ]] ; then
	sudo rm -f "$rust_conf"
fi

if [[ -f "$rust_fish_conf" ]] ; then
	sudo rm -f "$rust_fish_conf"
fi

}

if show_warning "rust" "$rustup_dir and $cargo_dir" "$@" ; then
	main "$@"
fi
