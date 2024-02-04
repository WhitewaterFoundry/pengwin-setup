#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling poetry"
  local tempPath

  curl -sSL https://install.python-poetry.org | python3 - --uninstall

  sudo_rem_file "/usr/share/bash-completion/completions/poetry"
  rem_file "${HOME}/.config/fish/completions/poetry.fish"
  rem_dir "${HOME}/.local/share/pypoetry"
}

if show_warning "poetry" "$@"; then
  main "$@"
fi
