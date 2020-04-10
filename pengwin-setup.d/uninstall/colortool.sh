#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

colortool_dir="$wHome/.ColorTool"

function main() {

  echo "Uninstalling ColorTool"

  rem_dir "$wHome/.ColorTool"
  sudo_rem_file "/usr/local/bin/colortool"

  echo "Removing PATH modifier..."
  sudo_rem_file "/etc/proflie.d/01-colortool.sh"

}

if show_warning "ColorTool" "$@"; then
  main "$@"
fi
