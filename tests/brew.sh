#!/bin/bash

source commons.sh

function test_main() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup install TOOLS HOMEBREW

  assertTrue "FILE PROFILE-BREW" "[ -f /etc/profile.d/brew.sh ]"
  run source /etc/profile.d/brew.sh
  assertEquals "Brew was not installed" "1" "$(run brew --version | grep -c 'Homebrew 5')"
}

function test_uninstall() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup uninstall HOMEBREW

  assertFalse "FILE PROFILE-BREW" "[ -f /etc/profile.d/brew.sh ]"
  assertEquals "Brew was still installed after uninstall" "0" "$(run brew --version | grep -c 'Homebrew 5')"
}

# shellcheck disable=SC1091
source shunit2
