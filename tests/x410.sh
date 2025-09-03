#!/bin/bash
# bashsupport disable=BP5005

source commons.sh
source mocks.sh

function testX410Tcp() {
  run_pengwinsetup install GUI CONFIGURE X410 TCP

  assertTrue "FILE PROFILE-X410" "[ -f /etc/profile.d/02-x410.sh ]"
  assertFalse "VSOCK NOT PRESENT" "grep -q '/vsock' /etc/profile.d/02-x410.sh"
}

function testX410Vsock() {
  run_pengwinsetup install GUI CONFIGURE X410 VSOCK

  assertTrue "FILE PROFILE-X410" "[ -f /etc/profile.d/02-x410.sh ]"
  assertTrue "VSOCK PRESENT" "grep -q '/vsock' /etc/profile.d/02-x410.sh"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL X410

  assertFalse "FILE PROFILE-X410" "[ -f /etc/profile.d/02-x410.sh ]"
}

# shellcheck disable=SC1091
source shunit2
