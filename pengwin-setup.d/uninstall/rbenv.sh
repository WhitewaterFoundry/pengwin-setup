#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling rbenv"

echo "Removing $HOME/.rbenv"
rm -rf "$HOME/.rbenv"

echo "Removing PATH modifiers"


}

show_warning "rbenv" "$HOME/.rbenv" "$@"
main "$@"
