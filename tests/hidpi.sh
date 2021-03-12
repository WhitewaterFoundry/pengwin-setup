#!/bin/bash

source commons.sh

function testDPI() {
  # shellcheck disable=SC2155
  local scale_factor=$(wslsys -S -s)

  run_pengwinsetup autoinstall GUI HIDPI
  assertEquals QT_SCALE_FACTOR "1" "$(grep -c "QT_SCALE_FACTOR=${scale_factor}" /etc/profile.d/hidpi.sh)"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL HIDPI

  test -f /etc/profile.d/hidpi.sh
  assertFalse "FILE HIDPI" "$?"
}

# shellcheck disable=SC1091
source shunit2
