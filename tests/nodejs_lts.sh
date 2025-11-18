#!/bin/bash

source commons.sh

#######################################
# description
# Arguments:
#  None
#######################################
function test_main() {
  run_pengwinsetup install PROGRAMMING NODEJS LTS --debug

  run npm --version
  run node --version
  run yarn --version

  assertEquals "npm was not installed" "1" "$(run npm --version | grep -c '11')"
  assertEquals "nodejs LTS was not installed" "1" "$(run node --version | grep -c 'v24')"

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

  assertEquals "npm was not uninstalled" "0" "$(run npm --version | grep -c '11')"
  assertEquals "nodejs LTS was not uninstalled" "0" "$(run node --version | grep -c 'v24')"

  run command -v yarn 2>/dev/null
  assertFalse "package yarn was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
