#!/bin/bash

source commons.sh

#######################################
# Test XDG user directories mapping installation
# Arguments:
#   None
#######################################
function test_main() {
  run_pengwinsetup install SETTINGS USERDIRS

  # Check that xdg-user-dirs package is installed
  for i in 'xdg-user-dirs'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  # Check that user-dirs.dirs file exists
  run test -f "$HOME/.config/user-dirs.dirs"
  assertTrue "user-dirs.dirs file was not created" "$?"
}

#######################################
# Test XDG user directories mapping uninstallation
# Arguments:
#   None
#######################################
function test_uninstall() {
  # First create some test symlinks
  local test_dirs=("Desktop" "Documents" "Downloads" "Music" "Pictures" "Videos" "Templates" "Public")

  for dir in "${test_dirs[@]}"; do
    if [[ -L "$HOME/$dir" ]]; then
      echo "Symlink exists for $dir"
    fi
  done

  run_pengwinsetup install UNINSTALL USERDIRS

  # After uninstall, the symlinks should be replaced with directories
  for dir in "${test_dirs[@]}"; do
    if [[ -L "$HOME/$dir" ]]; then
      assertFalse "Symlink for $dir should have been removed" "true"
    fi
  done
}

# shellcheck disable=SC1091
source shunit2
