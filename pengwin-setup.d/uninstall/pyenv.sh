#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

pyenv_dir="$HOME/.pyenv"
line_rgx='^[^#]*\bPATH.*/.pyenv/bin'
line2_rgx='^[^#]*\bpyenv init -'
line3_rgx='^[^#]*\bpyenv virtualenv-init -'

function main()
{

echo "Uninstalling pyenv"
local initFile

echo "Removing $pyenv_dir"
if [[ -d "$pyenv_dir" ]] ; then
	rm -rf "$pyenv_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier(s)"
initFile="$HOME/.bashrc"
if [[ -f "$initFile" ]] ; then
	echo "$initFile found! Cleaning..."
	clean_initfile "$initFile" "$line_rgx"
	clean_initfile "$initFile" "$line2_rgx"
	clean_initfile "$initFile" "$line3_rgx"
fi

initFile="$HOME/.zshrc"
if [[ -f "$initFile" ]] ; then
	echo "$initFile found! Cleaning..."
	clean_initfile "$initFile" "$line_rgx"
	clean_initfile "$initFile" "$line2_rgx"
	clean_initfile "$initFile" "$line3_rgx"
fi

initFile="$HOME/.config/fish"
if [[ -f "$initFile" ]] ; then
	echo "$initFile found! Cleaning..."
	clean_initfile "$initFile" "$line_rgx"
	clean_initfile "$initFile" "$line2_rgx"
	clean_initfile "$initFile" "$line3_rgx"
fi

}

if show_warning "pyenv" "$pyenv_dir" "$@" ; then
	main "$@"
fi
