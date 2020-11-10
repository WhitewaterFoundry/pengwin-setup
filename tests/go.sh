#!/bin/bash

source commons.sh
source mocks.sh

function testGo() {
  run_pengwinsetup autoinstall PROGRAMMING GO

  assertTrue "FILE PROFILE-GO" "[ -f /etc/profile.d/go.sh ]"
  assertTrue "FILE FISH-GO" "[ -f /etc/fish/conf.d/go.fish ]"

  source "/etc/profile.d/go.sh"

  command -v go
  assertEquals "GO was not installed" "0" "$?"

  assertEquals "GO was not installed" "1" "$(go version | grep -c '1.15.2')"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go ]"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go/pkg ]"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go/src ]"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go/bin ]"

}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL GO

  assertFalse "FILE PROFILE-GO" "[ -f /etc/profile.d/go.sh ]"
  assertFalse "FILE FISH-GO" "[ -f /etc/fish/conf.d/go.fish ]"

  command -v go
  assertEquals "Go was not uninstalled" "1" "$?"

}

source shunit2
