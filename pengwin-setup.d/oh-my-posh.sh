#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "OH MY POSH" --yesno "Would you like to download and install Oh My Posh, a prompt theme engine for any shell?" 8 70); then
  echo "Installing Oh My Posh"

  install_packages curl

  local_bin="${HOME}/.local/bin"
  mkdir -p "${local_bin}"

  if ! curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "${local_bin}"; then
    echo "Failed to install Oh My Posh" >&2
    exit 1
  fi

  echo "Oh My Posh installed to ${local_bin}/oh-my-posh"

  # Configure bash
  if [[ -f "${HOME}/.bashrc" && $(grep -c 'oh-my-posh init bash' "${HOME}/.bashrc") == 0 ]]; then
    echo "" >>"${HOME}/.bashrc"
    echo "# Oh My Posh" >>"${HOME}/.bashrc"
    echo "eval \"\$(oh-my-posh init bash)\"" >>"${HOME}/.bashrc"
  fi

  # Configure zsh
  if [[ -f "${HOME}/.zshrc" && $(grep -c 'oh-my-posh init zsh' "${HOME}/.zshrc") == 0 ]]; then
    echo "" >>"${HOME}/.zshrc"
    echo "# Oh My Posh" >>"${HOME}/.zshrc"
    echo "eval \"\$(oh-my-posh init zsh)\"" >>"${HOME}/.zshrc"
  fi

  # Configure fish
  if [[ -d "${HOME}/.config/fish" && $(grep -c 'oh-my-posh init fish' "${HOME}/.config/fish/config.fish" 2>/dev/null) == 0 ]]; then
    mkdir -p "${HOME}/.config/fish"
    echo "" >>"${HOME}/.config/fish/config.fish"
    echo "# Oh My Posh" >>"${HOME}/.config/fish/config.fish"
    echo "oh-my-posh init fish | source" >>"${HOME}/.config/fish/config.fish"
  fi
else
  echo "Skipping Oh My Posh"
fi
