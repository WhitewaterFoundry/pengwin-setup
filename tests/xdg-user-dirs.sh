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
# Note: This test requires test_main to have run first to create symlinks.
# In WSL environment, symlinks would be created to Windows folders.
# In test environment without Windows, we verify the uninstall logic works.
# Arguments:
#   None
#######################################
function test_uninstall() {
  local test_dirs=("Desktop" "Documents" "Downloads" "Music" "Pictures" "Videos" "Templates" "Public")

  # Run uninstall
  run_pengwinsetup install UNINSTALL USERDIRS

  # After uninstall, any symlinks that were created should be replaced with directories
  # or not be symlinks anymore
  for dir in "${test_dirs[@]}"; do
    run test -L "$HOME/$dir"
    local is_symlink=$?
    # If it's still a symlink, the uninstall didn't work properly
    assertNotEquals "Symlink for $dir should have been removed" "0" "$is_symlink"
  done
}

# shellcheck disable=SC1091
source shunit2
