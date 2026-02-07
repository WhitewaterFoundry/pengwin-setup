#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Synaptic"

  remove_package "synaptic"

}

if show_warning "synaptic" "$@"; then
  main "$@"
fi
