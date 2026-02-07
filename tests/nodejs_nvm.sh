#!/bin/bash

source commons.sh

#######################################
# Test Node.js installation with nvm in WSL2 mode
# Arguments:
#  None
#######################################
function test_main() {
  # Set WSL2=1 to test WSL2 behavior (full versions available)
  export WSL2=1
  
  run_pengwinsetup install PROGRAMMING NODEJS NVM

  assertTrue "FILE PROFILE-NVM" "[ -f /etc/profile.d/nvm-prefix.sh ]"

  source /etc/profile.d/nvm-prefix.sh

  run nvm --version
  run npm --version
  run node --version
  run yarn --version

  assertEquals "NVM was not installed" "1" "$(run nvm --version | grep -c '0\.40')"
  assertEquals "npm was not installed" "1" "$(run npm --version | grep -c '11')"
  assertEquals "nodejs LTS was not installed" "1" "$(run node --version | grep -c 'v24')"

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

  assertFalse "FILE PROFILE-NVM" "[ -f /etc/profile.d/nvm-prefix.sh ]"

  assertEquals "NVM was not uninstalled" "0" "$(run nvm --version | grep -c '0\.40')"
  assertEquals "npm was not uninstalled" "0" "$(run npm --version | grep -c '11')"
  assertEquals "nodejs LTS was not uninstalled" "0" "$(run node --version | grep -c 'v24')"

  run command -v yarn 2>/dev/null
  assertFalse "package yarn was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
