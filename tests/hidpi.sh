#!/bin/bash

source commons.sh

function testDPI() {
  # shellcheck disable=SC2155
  local scale_factor=$(wslsys -S -s)

  run_pengwinsetup autoinstall GUI HIDPI
  assertEquals scale_factor "1" "$(grep -c "scale_factor=${scale_factor}" /etc/profile.d/hidpi.sh)"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL HIDPI

  test -f /etc/profile.d/hidpi.sh
  assertFalse "FILE HIDPI" "$?"
}

# shellcheck disable=SC1091
source shunit2
