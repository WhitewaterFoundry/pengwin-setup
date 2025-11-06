#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling GitHub Copilot for Vim/Neovim"

  # Remove copilot.vim plugin from vim
  if [[ -d "${HOME}/.vim/plugged/copilot.vim" ]]; then
    echo "Removing GitHub Copilot plugin from Vim..."
    rm -rf "${HOME}/.vim/plugged/copilot.vim"
  fi

  # Remove copilot.vim plugin from neovim
  if [[ -d "${HOME}/.local/share/nvim/plugged/copilot.vim" ]]; then
    echo "Removing GitHub Copilot plugin from Neovim..."
    rm -rf "${HOME}/.local/share/nvim/plugged/copilot.vim"
  fi

  # Remove copilot configuration from .vimrc
  if [[ -f "${HOME}/.vimrc" ]]; then
    if grep -q "Plug 'github/copilot.vim'" "${HOME}/.vimrc" 2>/dev/null; then
      echo "Removing GitHub Copilot configuration from .vimrc..."
      # Create temporary file without the copilot.vim plugin line
      grep -v "Plug 'github/copilot.vim'" "${HOME}/.vimrc" > "${HOME}/.vimrc.tmp"
      mv "${HOME}/.vimrc.tmp" "${HOME}/.vimrc"
    fi
  fi

  # Remove copilot configuration from init.vim
  if [[ -f "${HOME}/.config/nvim/init.vim" ]]; then
    if grep -q "Plug 'github/copilot.vim'" "${HOME}/.config/nvim/init.vim" 2>/dev/null; then
      echo "Removing GitHub Copilot configuration from init.vim..."
      # Create temporary file without the copilot.vim plugin line
      grep -v "Plug 'github/copilot.vim'" "${HOME}/.config/nvim/init.vim" > "${HOME}/.config/nvim/init.vim.tmp"
      mv "${HOME}/.config/nvim/init.vim.tmp" "${HOME}/.config/nvim/init.vim"
    fi
  fi

  # Remove copilot data directory
  if [[ -d "${HOME}/.config/github-copilot" ]]; then
    echo "Removing GitHub Copilot data directory..."
    rm -rf "${HOME}/.config/github-copilot"
  fi

  echo "GitHub Copilot for Vim/Neovim uninstalled successfully"
  echo "Note: vim-plug and Vim/Neovim itself were not removed"
}

if show_warning "GitHub Copilot for Vim/Neovim" "$@"; then
  main "$@"
fi
