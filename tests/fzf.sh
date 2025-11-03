#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS FZF

  assertTrue "FZF directory not found" "[ -d ${HOME}/.fzf ]"
  
  command -v fzf
  assertEquals "FZF was not installed" "0" "$?"

  assertEquals "FZF was not installed" "1" "$(run fzf --version | grep -c 'fzf')"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL FZF

  assertFalse "FZF directory still exists" "[ -d ${HOME}/.fzf ]"

  command -v fzf
  assertEquals "FZF was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
