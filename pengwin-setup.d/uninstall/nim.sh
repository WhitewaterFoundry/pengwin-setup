#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  rem_dir "$HOME/.choosenim"
  rem_dir "$HOME/.nimble"
  sudo_rem_file "/etc/profile.d/nim.sh"

}

if show_warning "nim" "$@"; then
  main "$@"
fi
