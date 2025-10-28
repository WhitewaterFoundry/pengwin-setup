#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling JetBrains Toolbox"

  echo "Removing JetBrains Toolbox installation directory"
  rem_dir "$HOME/.local/share/JetBrains/Toolbox"

  echo "Removing JetBrains Toolbox symlink"
  rem_file "$HOME/.local/bin/jetbrains-toolbox"
}

if show_warning "JetBrains Toolbox" "$@"; then
  main "$@"
fi
