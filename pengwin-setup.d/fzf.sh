#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (confirm --title "FZF" --yesno "Would you like to download and install command line finder fzf?" 8 80); then
  echo "Installing FZF"
  
  install_packages git

  FZF_DIR="${HOME}/.fzf"

  if [[ -d "${FZF_DIR}/.git" ]]; then
    echo "FZF already installed, updating repository"
    cd "${FZF_DIR}" || exit 1
    if ! git pull --ff-only 2>&1; then
      echo "Failed to update existing FZF repository. This may be due to local changes or divergent branches." >&2
      echo "To resolve manually: cd ${FZF_DIR} && git status" >&2
      exit 1
    fi
  else
    # Remove any stale directory and clone a fresh copy
    if [[ -d "${FZF_DIR}" ]]; then
      echo "Removing existing non-git FZF directory at ${FZF_DIR}"
      rm -rf "${FZF_DIR}"
    fi
    if ! git clone --depth 1 https://github.com/junegunn/fzf.git "${FZF_DIR}"; then
      echo "Failed to clone FZF repository" >&2
      exit 1
    fi
    cd "${FZF_DIR}" || exit 1
  fi

  # The --all flag enables auto-completion and key bindings for all supported shells without prompting.
  if [[ -x ./install ]]; then
    ./install --all
  else
    echo "FZF install script not found or not executable in ${FZF_DIR}" >&2
    exit 1
  fi
else
  echo "Skipping FZF"
fi
