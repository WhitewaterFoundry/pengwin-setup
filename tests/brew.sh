#!/bin/bash

source commons.sh

function testMain() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup install TOOLS HOMEBREW

  assertTrue "FILE PROFILE-BREW" "[ -f /etc/profile.d/brew.sh ]"
  assertEquals "Brew was not installed" "1" "$(run_command_as_testuser brew --version | grep -c 'Homebrew 4')"
}

function testUninstall() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup uninstall HOMEBREW

  assertFalse "FILE PROFILE-BREW" "[ -f /etc/profile.d/brew.sh ]"

  assertEquals "Brew was not uninstalled" "0" "$(run_command_as_testuser brew --version | grep -c 'Homebrew 4')"
}

# shellcheck disable=SC1091
source shunit2
