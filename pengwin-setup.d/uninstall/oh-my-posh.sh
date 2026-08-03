#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Oh My Posh"

  rem_file "${HOME}/.local/bin/oh-my-posh"

}

if show_warning "Oh My Posh" "$@"; then
  main "$@"
fi
