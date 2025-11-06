#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install AI COPILOT-VIM

  # Check if vim-plug is installed for vim or neovim
  local vim_plug_found=false
  if [[ -f "${HOME}/.vim/autoload/plug.vim" ]] || [[ -f "${HOME}/.local/share/nvim/site/autoload/plug.vim" ]]; then
    vim_plug_found=true
  fi
  assertTrue "vim-plug was not installed" "${vim_plug_found}"

  # Check if copilot.vim plugin directory exists (for vim or neovim)
  local copilot_found=false
  if [[ -d "${HOME}/.vim/plugged/copilot.vim" ]] || [[ -d "${HOME}/.local/share/nvim/plugged/copilot.vim" ]]; then
    copilot_found=true
  fi
  assertTrue "GitHub Copilot plugin was not installed" "${copilot_found}"

  # Check if configuration file contains copilot reference
  local config_found=false
  if [[ -f "${HOME}/.vimrc" ]] && grep -q "github/copilot.vim" "${HOME}/.vimrc"; then
    config_found=true
  fi
  if [[ -f "${HOME}/.config/nvim/init.vim" ]] && grep -q "github/copilot.vim" "${HOME}/.config/nvim/init.vim"; then
    config_found=true
  fi
  assertTrue "GitHub Copilot not configured in vim/neovim config" "${config_found}"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL COPILOT-VIM

  # Check if copilot.vim plugin is removed
  assertFalse "GitHub Copilot plugin still exists in vim" "[ -d ${HOME}/.vim/plugged/copilot.vim ]"
  assertFalse "GitHub Copilot plugin still exists in neovim" "[ -d ${HOME}/.local/share/nvim/plugged/copilot.vim ]"

  # Check if configuration is removed from .vimrc
  if [[ -f "${HOME}/.vimrc" ]]; then
    run grep -q "github/copilot.vim" "${HOME}/.vimrc"
    assertFalse "GitHub Copilot still configured in .vimrc" "$?"
  fi

  # Check if configuration is removed from init.vim
  if [[ -f "${HOME}/.config/nvim/init.vim" ]]; then
    run grep -q "github/copilot.vim" "${HOME}/.config/nvim/init.vim"
    assertFalse "GitHub Copilot still configured in init.vim" "$?"
  fi

  # Check if copilot data directory is removed
  assertFalse "GitHub Copilot data directory still exists" "[ -d ${HOME}/.config/github-copilot ]"
}

# shellcheck disable=SC1091
source shunit2
