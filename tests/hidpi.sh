#!/bin/bash

source commons.sh

function testDPI() {
  scale_factor=$(wslsys -S -s)

  run_pengwinsetup autoinstall GUI HIDPI --debug
  assertEquals QT_SCALE_FACTOR "1" "$(grep -c "QT_SCALE_FACTOR=${scale_factor}" /etc/profile.d/hidpi.sh)"
}

function testUninstall() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive UNINSTALL HIDPI > /dev/null 2>&1

  test -f /etc/profile.d/hidpi.sh
  assertFalse "FILE HIDPI" "$?"
}

source shunit2
