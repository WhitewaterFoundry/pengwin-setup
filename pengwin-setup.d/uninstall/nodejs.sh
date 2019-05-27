#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

node_dir="$HOME/n"
yarn_src="/etc/apt/sources.list.d/yarn.list"
yarn_key='72EC F46A 56B4 AD39 C907  BBB7 1646 B01B 86E5 0310'
line_rgx='^[^#]*\bN_PREFIX='

function main()
{

echo "Uninstalling nodejs (including n version manager, npm and yarn package managers)"

echo "Removing $node_dir"
if [[ -d "$node_dir" ]] ; then
	rm -rf "$node_dir"
	rm -rf "$HOME/.npm" # also exists for package caches
else
	echo "... not found!"
fi

# Removing Yarn APT package + source
remove_package "yarn"

echo "Removing APT source"
if [[ -f "$yarn_src" ]] ; then
	sudo rm -f "$yarn_src"
else
	echo "... not found!"
fi

echo "Removing APT key"
sudo apt-key del "$yarn_key"

echo "Removing PATH modifier(s)"
if [[ -f "$HOME/.bashrc" ]] ; then
	echo "$HOME/.bashrc found, cleaning"
	clean_file "$HOME/.bashrc" "$line_rgx"
fi

if [[ -f "$HOME/.zshrc" ]] ; then
	echo "$HOME/.zshrc found, cleaning"
	clean_file "$HOME/.zshrc" "$line_rgx"
fi

# Node install script doesn't support automatic Fish shell config

}

if show_warning "node" "$node_dir" "$@" ; then
	main "$@"
fi
