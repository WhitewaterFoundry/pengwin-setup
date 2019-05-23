#!/bin/bash

source $(dirname "$@")/uninstall-common.sh

pyenv_dir="$HOME/.pyenv"

function main()
{

pyenv_conf="$HOME/.bashrc"

echo "Uninstalling pyenv"

echo "Removing $HOME/.pyenv"
if [[ -d "$pyenv_dir" ]] ; then
	rm -rf "$pyenv_dir"
else
	echo "... not found!"
fi

echo "Removing PATH modifier"


}

if show_warning "pyenv" "$pyenv_dir" "$@" ; then
	main "$@"
fi
