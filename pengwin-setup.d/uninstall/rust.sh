#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

rust_rgx='^[^#]*\PATH.*/.cargo/bin'
rust_env='^[^#]*\PATH.*/.cargo/env'

function main() {

  echo "Uninstalling rust"

  rem_dir "$HOME/.rustup"
  rem_dir "$HOME/.cargo"

  echo "Removing PATH modifier(s)..."
  sudo_rem_file "/etc/profile.d/rust.sh"
  sudo_rem_file "/etc/fish/conf.d/rust.sh"
  clean_file "$HOME/.profile" "$rust_rgx"
  clean_file "$HOME/.profile" "$rust_env"
  clean_file "$HOME/.bashrc" "$rust_env"
}

if show_warning "rust" "$@"; then
  main "$@"
fi
