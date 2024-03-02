#!/bin/bash

source commons.sh

#######################################
# Arguments:
#  None
#######################################
function test_dpi() {
  # shellcheck disable=SC2155
  local scale_factor=$(wslsys -S -s)

  run_pengwinsetup install GUI HIDPI
  assertEquals scale_factor "1" "$(grep -c "scale_factor=${scale_factor}" /etc/profile.d/hidpi.sh)"
}

#######################################
# Arguments:
#  None
#######################################
function test_uninstall() {

  run_pengwinsetup install UNINSTALL HIDPI

  test -f /etc/profile.d/hidpi.sh
  assertFalse "FILE HIDPI" "$?"
}

# shellcheck disable=SC1091
source shunit2
