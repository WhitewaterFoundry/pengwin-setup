#!/bin/bash

source commons.sh

function test_main() {
  # Test installing WezTerm for Linux
  run_pengwinsetup install GUI TERMINAL WEZTERM LINUX

  # Check that the APT repository was added
  assertTrue "WezTerm APT source not found" "[ -f /etc/apt/sources.list.d/wezterm.list ]"

  # Check that the GPG key was added
  assertTrue "WezTerm GPG key not found" "[ -f /usr/share/keyrings/wezterm-fury.gpg ]"

  # Check that wezterm package is installed
  package_installed wezterm
  assertTrue "wezterm package is not installed" "$?"

  # Check that wezterm binary exists
  command -v wezterm
  assertEquals "wezterm binary was not installed" "0" "$?"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL WEZTERM

  # Check that the APT repository was removed
  assertFalse "WezTerm APT source still exists" "[ -f /etc/apt/sources.list.d/wezterm.list ]"

  # Check that the GPG key was removed
  assertFalse "WezTerm GPG key still exists" "[ -f /usr/share/keyrings/wezterm-fury.gpg ]"

  # Check that wezterm package is not installed
  package_installed wezterm
  assertFalse "wezterm package is still installed" "$?"
}

# shellcheck disable=SC1091
source shunit2
