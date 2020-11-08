#!/bin/bash

source commons.sh
source mocks.sh

function testGo() {
  run_pengwinsetup autoinstall PROGRAMMING GO --debug

  assertTrue "FILE PROFILE-GO" "[ -f /etc/profile.d/go.sh ]"
  assertTrue "FILE FISH-GO" "[ -f /etc/fish/conf.d/go.fish ]"

  source "/etc/profile.d/go.sh"

  command -v go
  assertEquals "GO was not installed" "0" "$?"

  assertEquals "GO was not installed" "1" "$(run_command_as_testuser go version | grep -c '1.15.2')"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go ]"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go/pkg ]"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go/src ]"
  assertTrue "FILE DEFAULT-STRUCT-GO" "[ -d /home/${TEST_USER}/go/bin ]"

  #WSL2= bash /etc/profile.d/02-x410.sh
  #verify_call "cmd.exe /c x410.exe /wm"
  #assertTrue "X410 WSL1" "$?"

  #WSL2=1 bash /etc/profile.d/02-x410.sh
  #verify_call "cmd.exe /c x410.exe /wm /public"
  #assertTrue "X410 WSL2" "$?"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL GO

  assertFalse "FILE PROFILE-GO" "[ -f /etc/profile.d/go.sh ]"
  assertFalse "FILE FISH-GO" "[ -f /etc/fish/conf.d/go.fish ]"

  command -v go
  assertEquals "Go was not uninstalled" "1" "$?"

}

source shunit2
