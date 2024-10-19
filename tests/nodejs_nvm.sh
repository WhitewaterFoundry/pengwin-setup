#!/bin/bash

source commons.sh

#######################################
# description
# Arguments:
#  None
#######################################
function test_main() {
  run_pengwinsetup install PROGRAMMING NODEJS NVM

  assertTrue "FILE PROFILE-NVM" "[ -f /etc/profile.d/nvm-prefix.sh ]"

  source /etc/profile.d/nvm-prefix.sh

  run nvm --version
  run npm --version
  run node --version

  assertEquals "NVM was not installed" "1" "$(run nvm --version | grep -c '0\.40')"
  assertEquals "npm was not installed" "1" "$(run npm --version | grep -c '10')"
  assertEquals "nodejs latest was not installed" "1" "$(run node --version | grep -c 'v23')"

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

  assertFalse "FILE PROFILE-NVM" "[ -f /etc/profile.d/nvm-prefix.sh ]"

  assertEquals "NVM was not uninstalled" "0" "$(run nvm --version | grep -c '0\.39')"
  assertEquals "npm was not uninstalled" "0" "$(run npm --version | grep -c '10')"
  assertEquals "nodejs latest was not uninstalled" "0" "$(run node --version | grep -c 'v23')"

  run command -v yarn 2>/dev/null
  assertFalse "package yarn was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
