#!/bin/bash

source commons.sh

function testDPI() {
  scale_factor=$(wslsys -S -s)

  ../pengwin-setup --noupdate --assume-yes --noninteractive GUI HIDPI
  assertEquals QT_SCALE_FACTOR "1" "$(grep -c "QT_SCALE_FACTOR=${scale_factor}" /etc/profile.d/hidpi.sh)"
  assertEquals GDK_SCALE "1" "$(grep -c "GDK_SCALE" /etc/profile.d/hidpi.sh)"
}

function testUninstall() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive UNINSTALL HIDPI
  assertFalse "FILE HIDPI" "$([ -f /etc/profile.d/hidpi.sh ])"
}

source shunit2
