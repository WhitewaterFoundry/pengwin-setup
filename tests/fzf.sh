#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS FZF

  assertTrue "FZF directory not found" "[ -d ${HOME}/.fzf ]"
  assertTrue "FZF binary not found" "[ -f ${HOME}/.fzf/bin/fzf ]"
  
  assertEquals "FZF was not installed" "1" "$(run ${HOME}/.fzf/bin/fzf --version | grep -c 'fzf')"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL FZF

  assertFalse "FZF directory still exists" "[ -d ${HOME}/.fzf ]"
  assertFalse "FZF binary still exists" "[ -f ${HOME}/.fzf/bin/fzf ]"
}

# shellcheck disable=SC1091
source shunit2
