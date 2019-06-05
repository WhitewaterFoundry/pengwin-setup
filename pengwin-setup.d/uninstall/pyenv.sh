#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

line_rgx='^[^#]*\bPATH.*/.pyenv/bin'
line2_rgx='^[^#]*\bpyenv init -'
line3_rgx='^[^#]*\bpyenv virtualenv-init -'

function multiclean_file()
{

if [[ -f "$1" ]] ; then
	echo "$1 found! Cleaning..."
	clean_file "$1" "$line_rgx"
	clean_file "$1" "$line2_rgx"
	clean_file "$1" "$line3_rgx"
fi

}

function main()
{

echo "Uninstalling pyenv"
local initFile

rem_dir "$HOME/.pyenv"

echo "Removing PATH modifier(s)"
multiclean_file "$HOME/.bashrc"
multiclean_file "$HOME/.zshrc"
multiclean_file "$HOME/.config/fish"

}

if show_warning "pyenv" "$@" ; then
	main "$@"
fi
