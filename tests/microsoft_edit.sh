#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install EDITORS MSEDIT

  assertTrue "Microsoft Edit binary missing" "[ -f /usr/local/bin/edit ]"
  command -v /usr/local/bin/edit
  assertEquals "Microsoft Edit was not installed" "0" "$?"
  assertEquals "update-alternatives not configured" "1" "$(run update-alternatives --list editor | grep -c '/usr/local/bin/edit')"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL MSEDIT

  assertFalse "Microsoft Edit binary still present" "[ -f /usr/local/bin/edit ]"
  assertEquals "update-alternatives entry still present" "0" "$(run update-alternatives --list editor | grep -c '/usr/local/bin/edit')"
}

# shellcheck disable=SC1091
source shunit2
