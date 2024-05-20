#!/bin/bash

source commons.sh

#######################################
# description
# Arguments:
#  None
#######################################
function test_main() {
  run_pengwinsetup install PROGRAMMING NODEJS LATEST

  run npm --version
  run node --version

  assertEquals "npm was not installed" "1" "$(run npm --version | grep -c '9')"
  assertEquals "nodejs latest was not installed" "1" "$(run node --version | grep -c 'v22')"

  run command -v yarn >/dev/null
  assertTrue "package yarn is not installed" "$?"
}

#######################################
# description
# Arguments:
#  None
#######################################
function test_uninstall() {
  run_pengwinsetup uninstall NODEJS

  assertFalse "FILE PROFILE-NVERMAN" "[ -f /etc/profile.d/n-prefix.sh ]"

  assertEquals "npm was not uninstalled" "0" "$(run npm --version | grep -c '9')"
  assertEquals "nodejs latest was not uninstalled" "0" "$(run node --version | grep -c 'v22')"

  run command -v yarn 2>/dev/null
  assertFalse "package yarn was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
