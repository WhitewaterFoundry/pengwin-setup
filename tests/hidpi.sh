#!/bin/bash

source commons.sh

function testDPI() {
  scale_factor=$(wslsys -S -s)

  run_pengwinsetup autoinstall GUI HIDPI
  assertEquals QT_SCALE_FACTOR "1" "$(grep -c "QT_SCALE_FACTOR=${scale_factor}" /etc/profile.d/hidpi.sh)"
}

function testUninstall() {

  run_pengwinsetup autoinstall UNINSTALL HIDPI

  test -f /etc/profile.d/hidpi.sh
  assertFalse "FILE HIDPI" "$?"
}

source shunit2
