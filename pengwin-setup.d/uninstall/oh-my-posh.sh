#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Oh My Posh"

  rem_file "${HOME}/.local/bin/oh-my-posh"

  echo "Removing Oh My Posh shell configuration..."
  if [[ -f "${HOME}/.bashrc" ]]; then
    clean_file "${HOME}/.bashrc" '# Oh My Posh|oh-my-posh init bash'
  fi

  if [[ -f "${ZDOTDIR:-$HOME}/.zshrc" ]]; then
    clean_file "${ZDOTDIR:-$HOME}/.zshrc" '# Oh My Posh|oh-my-posh init zsh'
  fi

  if [[ -f "${HOME}/.config/fish/config.fish" ]]; then
    clean_file "${HOME}/.config/fish/config.fish" '# Oh My Posh|oh-my-posh init fish'
  fi

}

if show_warning "Oh My Posh" "$@"; then
  main "$@"
fi
