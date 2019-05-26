#!/bin/bash

source $(dirname "$@")/uninstall-common.sh

node_dir="$HOME/n"

function main()
{

echo "Uninstalling nodejs (including n version manager, npm and yarn package managers)"

echo "Removing $node_dir"
if [[ -d "$node_dir" ]] ; then
	rm -rf "$node_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier(s)"
if [[ -f "$HOME/.bashrc" ]] ; then
	echo "$HOME/.bashrc found, cleaning"
	sed -i
fi

if [[ -f "" ]] ; then
	echo "$HOME/.zshrc found, cleaning"
	sed -i
fi

if [[ -f "$HOME/.config/fish" ]] ; then
	echo "$HOME/.config/fish found, cleaning"
	sed -i
fi

}

if show_warning "node" "$node_dir" "$@" ; then
	main "$@"
fi
