#!/bin/bash
# bashsupport disable=BP5005

source commons.sh
source mocks.sh

function testX410() {
  run_pengwinsetup install GUI CONFIGURE X410

  assertTrue "FILE PROFILE-X410" "[ -f /etc/profile.d/02-x410.sh ]"

  #WSL2= bash /etc/profile.d/02-x410.sh
  #verify_call "cmd.exe /c x410.exe /wm"
  #assertTrue "X410 WSL1" "$?"

  #WSL2=1 bash /etc/profile.d/02-x410.sh
  #verify_call "cmd.exe /c x410.exe /wm /public"
  #assertTrue "X410 WSL2" "$?"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL X410

  assertFalse "FILE PROFILE-X410" "[ -f /etc/profile.d/02-x410.sh ]"
}

# shellcheck disable=SC1091
source shunit2
