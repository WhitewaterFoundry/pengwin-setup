#!/bin/bash

source commons.sh

function testRCLOCAL() {
  run_pengwinsetup autoinstall SERVICES RCLOCAL

  assertTrue "FILE RCLOCAL" "[ -f /etc/rc.local ]"
  assertTrue "FILE PROFILE-RCLOCAL" "[ -f /etc/profile.d/rclocal.sh ]"
  assertTrue "FILE SUDOERS-RCLOCAL" "[ -f /etc/sudoers.d/rclocal ]"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL RCLOCAL

  assertTrue "FILE RCLOCAL" "[ -f /etc/rc.local ]"
  assertFalse "FILE PROFILE-RCLOCAL" "[ -f /etc/profile.d/rclocal.sh ]"
  assertFalse "FILE SUDOERS-RCLOCAL" "[ -f /etc/sudoers.d/rclocal ]"
}

# shellcheck disable=SC1091
source shunit2
