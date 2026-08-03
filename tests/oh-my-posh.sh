#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS OHMYPOSH

  assertTrue "oh-my-posh binary not found" "[ -f ${HOME}/.local/bin/oh-my-posh ]"
  assertTrue "oh-my-posh binary not executable" "[ -x ${HOME}/.local/bin/oh-my-posh ]"

  run "${HOME}/.local/bin/oh-my-posh" --version
  assertEquals "oh-my-posh version command failed" "0" "$?"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL OHMYPOSH

  assertFalse "oh-my-posh binary still exists" "[ -f ${HOME}/.local/bin/oh-my-posh ]"
}

# shellcheck disable=SC1091
source shunit2
