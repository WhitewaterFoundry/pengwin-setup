#!/bin/bash

source $(dirname "$@")/uninstall-common.sh

function main()
{

echo "Uninstalling pyenv"

echo "Removing $HOME/.pyenv"
rm -rf "$HOME/.pyenv"

echo "Removing PATH modifiers"


}

show_warning "pyenv" "$HOME/.pyenv" "$@"
main "$@"
