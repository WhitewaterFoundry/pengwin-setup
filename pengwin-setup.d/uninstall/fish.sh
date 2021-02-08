#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstall fish"
  createtmp

  curl -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install > install
  fish install --path=~/.local/share/omf --config=~/.config/omf --yes --noninteractive --uninstall

  cleantmp

  sudo chsh -s "$(command -v bash)" "${USER}"

  sudo_rem_file "${__fish_sysconf_dir:=/etc/fish/conf.d}/update-motd.fish"

  echo "Removing fish package..."
  remove_package "fish"

}

if show_warning "fish" "$@"; then
  main "$@"
fi
