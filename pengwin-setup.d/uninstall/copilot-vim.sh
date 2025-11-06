#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling GitHub Copilot for Vim/Neovim"

  # Remove copilot.vim plugin from vim
  rem_dir "${HOME}/.vim/plugged/copilot.vim"

  # Remove copilot.vim plugin from neovim
  rem_dir "${HOME}/.local/share/nvim/plugged/copilot.vim"

  # Remove copilot configuration from .vimrc
  if [[ -f "${HOME}/.vimrc" ]]; then
    echo "Removing GitHub Copilot configuration from .vimrc..."
    clean_file "${HOME}/.vimrc" "Plug 'github/copilot.vim'"
  fi

  # Remove copilot configuration from init.vim
  if [[ -f "${HOME}/.config/nvim/init.vim" ]]; then
    echo "Removing GitHub Copilot configuration from init.vim..."
    clean_file "${HOME}/.config/nvim/init.vim" "Plug 'github/copilot.vim'"
  fi

  # Remove copilot data directory
  rem_dir "${HOME}/.config/github-copilot"

  echo "GitHub Copilot for Vim/Neovim uninstalled successfully"
  echo "Note: vim-plug and Vim/Neovim itself were not removed"
}

if show_warning "GitHub Copilot for Vim/Neovim" "$@"; then
  main "$@"
fi
