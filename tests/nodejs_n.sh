#!/bin/bash

source commons.sh

#######################################
# description
# Arguments:
#  None
#######################################
function test_main() {
  run_pengwinsetup install PROGRAMMING NODEJS NVERMAN

  assertTrue "FILE PROFILE-NVERMAN" "[ -f /etc/profile.d/n-prefix.sh ]"

  source /etc/profile.d/n-prefix.sh

  run n --version
  run npm --version
  run node --version
  run n list

  assertEquals "N was not installed" "1" "$(run n --version | grep -c 'v9')"
  assertEquals "npm was not installed" "1" "$(run npm --version | grep -c '10')"
  assertEquals "nodejs latest was not installed" "1" "$(run node --version | grep -c 'v22')"
  assertEquals "nodejs lts was not installed" "1" "$(run n list | grep -c 'node/20')"

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

  assertEquals "N was not uninstalled" "0" "$(run n --version | grep -c 'v9')"
  assertEquals "npm was not uninstalled" "0" "$(run npm --version | grep -c '10')"
  assertEquals "nodejs latest was not uninstalled" "0" "$(run node --version | grep -c 'v22')"
  assertEquals "nodejs lts was not uninstalled" "0" "$(run n list | grep -c 'node/20')"

  run command -v yarn 2>/dev/null
  assertFalse "package yarn was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
