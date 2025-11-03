#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling FZF"

  rem_dir "${HOME}/.fzf"

  echo "Removing FZF PATH modifications..."
  if [[ -f "${HOME}/.bashrc" ]]; then
    clean_file "${HOME}/.bashrc" '\[ -f ~/.fzf.bash \] && source ~/.fzf.bash'
  fi

  if [[ -f "${HOME}/.zshrc" ]]; then
    clean_file "${HOME}/.zshrc" '\[ -f ~/.fzf.zsh \] && source ~/.fzf.zsh'
  fi

  rem_file "${HOME}/.fzf.bash"
  rem_file "${HOME}/.fzf.zsh"
}

if show_warning "FZF" "$@"; then
  main "$@"
fi
