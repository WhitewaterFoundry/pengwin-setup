#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling nodejs (including n version manager, npm and yarn package managers)"

  # Check for ruby rails install
  echo "Checking if Ruby on Rails installed..."
  if gem list --local | grep '^rails' >/dev/null 2>&1; then
    echo "Rails install detected. Showing user warning"
    if ! (confirm --title "nodejs" --yesno "A Ruby on Rails install has been detected, which relies upon nodejs. Are you sure you'd like to continue uninstalling nodejs? As this may break your Ruby on Rails install" 9 85); then
      echo "User cancelled nodejs uninstall"
      exit 1
    fi
  fi

  corepack disable
  rm -rf ~/.local/share/corepack

  npm uninstall -g corepack
  sudo npm uninstall -g corepack

  if [[ -n "$N_PREFIX" && -x "${N_PREFIX}/bin/n-uninstall" ]]; then
    echo "Using first the native N uninstaller"
    "${N_PREFIX}/bin/n-uninstall" -y
  fi

  rem_dir "$HOME/n"
  rem_dir "$HOME/.npm"
  sudo_rem_dir "$HOME/.npm"
  rem_dir "$HOME/.nvm"

  echo "Removing PATH modifier(s)..."
  sudo_rem_file "/etc/profile.d/rm-win-npm-path.sh"

  # Bash + other shell config removal
  sudo_rem_file "/etc/profile.d/n-prefix.sh"
  sudo_rem_file "/etc/profile.d/nvm-prefix.sh"

  # Fish config removal
  local fish_conf_dir="$HOME/.config/fish/conf.d"
  rem_file "$fish_conf_dir/n-prefix.fish"
  rem_file "$fish_conf_dir/nvm-prefix.fish"

  # The .bashrc path clean shouldn't be needed on newer installs, but takes into account legacy pengwin-setup nodejs installs
  if [[ -f "$HOME/.bashrc" ]]; then
    echo "$HOME/.bashrc found, cleaning"
    local n_line_rgx='^[^#]*\bN_PREFIX='
    clean_file "$HOME/.bashrc" "$n_line_rgx"
  fi

  echo "Removing bash completion..."
  sudo_rem_file "/etc/bash_completion.d/npm"
  sudo_rem_file "/etc/bash_completion.d/nvm"

  remove_package "yarn" "nodejs"

  echo "Removing APT source(s)"
  sudo_rem_file "/etc/apt/sources.list.d/yarn.list"
  sudo_rem_file "/etc/apt/sources.list.d/nodesource.list"

  echo "Removing APT key(s)"
  sudo_rem_file /usr/share/keyrings/nodesource.gpg
  sudo_rem_file /etc/apt/keyrings/nodesource.gpg
}

if show_warning "nodejs" "$@"; then
  main "$@"
fi
