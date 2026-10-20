#!/bin/bash

source commons.sh

#######################################
# Test XDG user directories mapping installation
# Arguments:
#   None
#######################################
function test_main() {
  run mkdir -p "$HOME/windows" "$HOME/Desktop" "$HOME/Documents" \
    "$HOME/Downloads" "$HOME/Music" "$HOME/Pictures" "$HOME/Videos" \
    "$HOME/Templates" "$HOME/Public"
  for dir in Desktop Documents Downloads Music Pictures Videos Templates Public; do
    run mkdir -p "$HOME/windows/$dir"
  done
  run touch "$HOME/Documents/keep.txt"

  run_pengwinsetup install SETTINGS USERDIRS

  # Check that xdg-user-dirs package is installed
  package_installed 'xdg-user-dirs'
  assertTrue "package 'xdg-user-dirs' is not installed" "$?"

  # Check that user-dirs.dirs file exists
  run test -f "$HOME/.config/user-dirs.dirs"
  assertTrue "user-dirs.dirs file was not created" "$?"

  for dir in Desktop Downloads Music Pictures Videos Templates Public; do
    assertEquals "Wrong Windows mapping for $dir" \
      "$HOME/windows/$dir" "$(readlink "$HOME/$dir")"
  done

  run test -f "$HOME/Documents/keep.txt"
  assertTrue "non-empty Documents directory was not preserved" "$?"
  run test ! -L "$HOME/Documents"
  assertTrue "non-empty Documents directory was replaced" "$?"

  run mkdir -p "$HOME/Downloads=archive"
  run rm -f "$HOME/Downloads"
  run sed -i 's|^XDG_DOWNLOAD_DIR=.*|XDG_DOWNLOAD_DIR="$HOME/Downloads=archive"|' \
    "$HOME/.config/user-dirs.dirs"
  run_pengwinsetup install SETTINGS USERDIRS
  assertEquals "Path containing '=' was parsed incorrectly" \
    "$HOME/windows/Downloads" "$(readlink "$HOME/Downloads=archive")"

  run rm -f "$HOME/Desktop"
  run sed -i 's|^XDG_DESKTOP_DIR=.*|XDG_DESKTOP_DIR="$HOME/windows/Desktop"|' \
    "$HOME/.config/user-dirs.dirs"
  run_pengwinsetup install SETTINGS USERDIRS
  run test -d "$HOME/windows/Desktop"
  assertTrue "an already-mapped Windows directory was removed" "$?"
  run test ! -L "$HOME/windows/Desktop"
  assertTrue "an already-mapped Windows directory became a symlink" "$?"
}

#######################################
# Test XDG user directories mapping uninstallation
# Uses Windows folder fixtures provided by the wslvar and wslpath stubs.
# Arguments:
#   None
#######################################
function test_uninstall() {
  run rm -f "$HOME/.dialog-call-count"
  run bash "$PWD/../pengwin-setup.d/uninstall/xdg-user-dirs.sh" --dialog

  for dir in 'Downloads=archive' Music Pictures Videos Templates Public; do
    run test ! -L "$HOME/$dir"
    assertTrue "symlink for $dir was not removed" "$?"
    run test -d "$HOME/$dir"
    assertTrue "local directory for $dir was not restored" "$?"
  done
  run test -f "$HOME/.config/user-dirs.dirs"
  assertTrue "user-dirs.dirs file should remain when keeping the package" "$?"

  run_pengwinsetup install SETTINGS USERDIRS
  run_pengwinsetup install UNINSTALL USERDIRS

  # After uninstall with package removal, user-dirs.dirs should be deleted
  run test -f "$HOME/.config/user-dirs.dirs"
  assertFalse "user-dirs.dirs file should be deleted after uninstall" "$?"
  run test ! -L "$HOME/Downloads=archive"
  assertTrue "symlink should be removed after uninstall" "$?"
}

# shellcheck disable=SC1091
source shunit2
