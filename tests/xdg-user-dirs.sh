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
  package_installed 'xdg-user-dirs'
  assertTrue "package 'xdg-user-dirs' is not installed" "$?"

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
  # Run uninstall
  run_pengwinsetup install UNINSTALL USERDIRS

  # After uninstall, user-dirs.dirs should be deleted and regenerated
  # by xdg-user-dirs-update
  run test -f "$HOME/.config/user-dirs.dirs"
  assertFalse "user-dirs.dirs file should be deleted after uninstall" "$?"
}

# shellcheck disable=SC1091
source shunit2
