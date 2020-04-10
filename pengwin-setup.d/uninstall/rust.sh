#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

rust_rgx='^[^#]*\PATH.*/.cargo/bin'

function main() {

  echo "Uninstalling rust"

  rem_dir "$HOME/.rustup"
  rem_dir "$HOME/.cargo"

  echo "Removing PATH modifier(s)..."
  sudo_rem_file "/etc/profile.d/rust.sh"
  sudo_rem_file "/etc/fish/conf.d/rust.sh"
  clean_file "$HOME/.profile" "$rust_rgx"

}

if show_warning "rust" "$@"; then
  main "$@"
fi
