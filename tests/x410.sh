#!/bin/bash

source commons.sh

function testX410() {
  run_pengwinsetup autoinstall GUI X410 --debug

  assertTrue "FILE PROFILE-X410" "[ -f /etc/profile.d/02-x410.sh ]"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL X410

  assertFalse "FILE PROFILE-X410" "[ -f /etc/profile.d/02-x410.sh ]"
}

source shunit2
