#!/bin/bash

source commons.sh

function testMain() {
  run_pengwinsetup install PROGRAMMING JAVA

  check_script '/etc/profile.d/sdkman.sh'

  assertEquals "SDKMan was not installed" "1" "$(run sdk version | grep -c 'SDKMAN!')"
}

function testUninstall() {
  run_pengwinsetup uninstall JAVA

  assertFalse "FILE PROFILE-SDKMAN" "[ -f /etc/profile.d/sdkman.sh ]"

  assertEquals "SDKMan was not uninstalled" "0" "$(run sdk version | grep -c 'SDKMAN!')"
}

# shellcheck disable=SC1091
source shunit2
