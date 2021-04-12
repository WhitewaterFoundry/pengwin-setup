#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Homebrew"
  local tmp_ruby=1

  if ! ruby --version >/dev/null 2>&1; then
    echo "Installing Ruby for uninstall script"
    sudo apt-get install ruby -y -q
    tmp_ruby=0
  fi

  echo "Running Homebrew uninstall script"

  createtmp

  wget https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh
  if /bin/bash uninstall.sh --force; then
    echo "Successfully executed script"
  else
    if ! brew; then
      echo "Full uninstall failed. Removing remnants"
      sudo rm -rf "/home/linuxbrew"
      sudo rm -rf "$HOME/.linuxbrew"
    else
      echo "Uninstall failed"
    fi
  fi

  cleantmp

  echo "Removing PATH modification..."
  sudo_rem_file "/etc/profile.d/brew.sh"
  sudo_rem_file "/etc/fish/conf.d/brew.fish"

  if [ $tmp_ruby -eq 0 ]; then
    echo "Ruby temporarily installed for uninstall script, removing..."
    sudo apt-get remove -y -q ruby --autoremove
  fi

}

if show_warning "Homebrew" "$@"; then
  main "$@"
fi
