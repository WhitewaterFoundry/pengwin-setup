#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling rbenv"

  rem_dir "$HOME/.rbenv"

  echo "Removing PATH modifier(s)..."
  sudo_rem_file "/etc/profile.d/ruby.sh"
  sudo_rem_file "/etc/fish/conf.d/ruby.fish"

  # Check if Ruby on RAILS previously installed
  if [[ -d "$HOME/.gem" ]]; then
    echo "Ruby on RAILS previously installed"
    rem_dir "$HOME/.gem"
  fi

}

if show_warning "rbenv" "$@"; then
  main "$@"
fi
