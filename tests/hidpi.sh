#!/bin/bash

source commons.sh

function testDPI() {
  scale_factor=$(wslsys -S -s)
	scale_factor_int=$(IFS='.' read -r -a splitted <<< "${scale_factor}"; echo -n "${splitted[0]}")

  ../pengwin-setup --noupdate --assume-yes --noninteractive GUI HIDPI
  assertEquals QT_SCALE_FACTOR "1" "$(grep -c "QT_SCALE_FACTOR=${scale_factor}" /etc/profile.d/hidpi.sh)"
  assertEquals GDK_SCALE "1" "$(grep -c "GDK_SCALE=${scale_factor_int}" /etc/profile.d/hidpi.sh)"
}

function testUninstall() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive UNINSTALL HIDPI
  assertFalse "FILE HIDPI" "$([ -f /etc/profile.d/hidpi.sh ])"
}

source shunit2
