#!/bin/bash

source commons.sh

#######################################
# Test Node.js installation with n version manager in WSL2 mode
# Arguments:
#  None
#######################################
function test_main() {
  # Set WSL2=1 to test WSL2 behavior (full versions available)
  export WSL2=1
  
  run_pengwinsetup install PROGRAMMING NODEJS NVERMAN

  assertTrue "FILE PROFILE-NVERMAN" "[ -f /etc/profile.d/n-prefix.sh ]"

  source /etc/profile.d/n-prefix.sh

  run n --version
  run npm --version
  run node --version
  run n list

  assertEquals "N was not installed" "1" "$(run n --version | grep -c '10')"
  assertEquals "npm was not installed" "1" "$(run npm --version | grep -c '11')"
  assertEquals "nodejs lts was not installed" "1" "$(run n list | grep -c 'node/24')"

  run command -v yarn >/dev/null
  assertTrue "package yarn is not installed" "$?"
}

#######################################
# Test Node.js uninstallation
# Arguments:
#  None
#######################################
function test_uninstall() {
  run_pengwinsetup uninstall NODEJS

  assertFalse "FILE PROFILE-NVERMAN" "[ -f /etc/profile.d/n-prefix.sh ]"

  assertEquals "N was not uninstalled" "0" "$(run n --version | grep -c '10')"
  assertEquals "npm was not uninstalled" "0" "$(run npm --version | grep -c '11')"
  assertEquals "nodejs lts was not uninstalled" "0" "$(run n list | grep -c 'node/24')"

  run command -v yarn 2>/dev/null
  assertFalse "package yarn was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
