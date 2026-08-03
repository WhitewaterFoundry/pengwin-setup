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
  echo "To use Oh My Posh, add the following to your shell configuration:"
  echo "  For bash (~/.bashrc):"
  echo "    eval \"\$(oh-my-posh init bash)\""
  echo "  For zsh (~/.zshrc):"
  echo "    eval \"\$(oh-my-posh init zsh)\""
  echo "  For fish (~/.config/fish/config.fish):"
  echo "    oh-my-posh init fish | source"
else
  echo "Skipping Oh My Posh"
fi
