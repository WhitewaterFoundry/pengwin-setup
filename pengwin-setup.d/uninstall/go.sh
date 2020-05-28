#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling go"

  echo "Removing $go_dir"
  sudo_rem_dir "/usr/local/go"

  echo "Removing go build cache"
  rem_dir "$HOME/.cache/go-build"

  echo "Removing PATH modifier..."
  sudo_rem_file "/etc/profile.d/go.sh"

  # whiptail user go directory

}

if show_warning "go" "$@"; then
  main "$@"
fi
