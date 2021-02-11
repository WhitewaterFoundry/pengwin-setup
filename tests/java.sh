#!/bin/bash

source commons.sh

function testMain() {
set -x
  run_pengwinsetup install PROGRAMMING JAVA

  check_script '/etc/profile.d/sdkman.sh'

  chmod 777 -R "${HOME}/.sdkman"
  assertEquals "SDKMan was not installed" "1" "$(run_command_as_testuser sdk version | grep -c 'SDKMAN 5')"
  set +x
}

function testUninstall() {
  chmod 777 -R "${HOME}/.sdkman"

  run_pengwinsetup uninstall JAVA

  assertFalse "FILE PROFILE-SDKMAN" "[ -f /etc/profile.d/sdkman.sh ]"

  assertEquals "SDKMan was not uninstalled" "0" "$(run_command_as_testuser sdk version | grep -c 'SDKMAN 5')"
}

# shellcheck disable=SC1091
source shunit2
