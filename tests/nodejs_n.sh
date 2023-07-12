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

  assertEquals "N was not installed" "1" "$(run_command_as_testuser n --version | grep -c 'v9')"
  assertEquals "npm was not installed" "1" "$(run_command_as_testuser npm --version | grep -c '9')"
  assertEquals "nodejs latest was not installed" "1" "$(run_command_as_testuser node --version | grep -c 'v20')"
  assertEquals "nodejs lts was not installed" "1" "$(run_command_as_testuser n list | grep -c 'node/18')"

  package_installed 'yarn'
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

  assertEquals "N was not uninstalled" "0" "$(run_command_as_testuser n --version | grep -c 'v9')"
  assertEquals "npm was not uninstalled" "0" "$(run_command_as_testuser npm --version | grep -c '9')"
  assertEquals "nodejs latest was not uninstalled" "0" "$(run_command_as_testuser node --version | grep -c 'v20')"
  assertEquals "nodejs lts was not uninstalled" "0" "$(run_command_as_testuser n list | grep -c 'node/18')"

  package_installed 'yarn'
  assertFalse "package yarn was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
