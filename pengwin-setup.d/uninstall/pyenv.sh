#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

line_rgx='^[^#]*\bPATH.*/.pyenv/bin'
line2_rgx='^[^#]*\bpyenv init -'
line3_rgx='^[^#]*\bpyenv virtualenv-init -'

function main()
{

echo "Uninstalling pyenv"
local initFile

rem_dir "$HOME/.pyenv"

echo "Removing PATH modifier(s)"
initFile="$HOME/.bashrc"
if [[ -f "$initFile" ]] ; then
	echo "$initFile found! Cleaning..."
	clean_file "$initFile" "$line_rgx"
	clean_file "$initFile" "$line2_rgx"
	clean_file "$initFile" "$line3_rgx"
fi

initFile="$HOME/.zshrc"
if [[ -f "$initFile" ]] ; then
	echo "$initFile found! Cleaning..."
	clean_file "$initFile" "$line_rgx"
	clean_file "$initFile" "$line2_rgx"
	clean_file "$initFile" "$line3_rgx"
fi

initFile="$HOME/.config/fish"
if [[ -f "$initFile" ]] ; then
	echo "$initFile found! Cleaning..."
	clean_file "$initFile" "$line_rgx"
	clean_file "$initFile" "$line2_rgx"
	clean_file "$initFile" "$line3_rgx"
fi

}

if show_warning "pyenv" "$pyenv_dir" "$@" ; then
	main "$@"
fi
