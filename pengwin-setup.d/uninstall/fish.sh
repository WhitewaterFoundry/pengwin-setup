#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstall fish"
  createtmp

  curl -L https://get.oh-my.fish > install
  fish install --path=~/.local/share/omf --config=~/.config/omf --yes --noninteractive --uninstall

  cleantmp

  sudo chsh -s "$(command -v bash)" "${USER}"

  echo "Removing fish package..."
  remove_package "fish"

}

if show_warning "fish" "$@"; then
  main "$@"
fi
