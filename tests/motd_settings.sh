#!/bin/bash

source commons.sh

#######################################
# Arguments:
#  None
#######################################
function test_motd_never() {
  run_pengwinsetup install SETTINGS MOTD MOTD_NEVER

  run test -f "$HOME"/.hushlogin
  assertTrue "File .hushlogin not created" "$?"
}

#######################################
# Arguments:
#  None
#######################################
function test_motd_always() {
  run_pengwinsetup install SETTINGS MOTD MOTD_ALWAYS

  run test -f "$HOME"/.hushlogin
  assertTrue "File .hushlogin not created" "$?"

  run test -f "$HOME"/.motd_show_always
  assertTrue "File .motd_show_always not created" "$?"
}

#######################################
# Arguments:
#  None
#######################################
function test_motd_once_per_day() {

  run_pengwinsetup install SETTINGS MOTD MOTD_ONCE_PER_DAY

  run test -f $HOME/.hushlogin
  assertFalse "FILE .hushlogin still present" "$?"
  run test -f "$HOME"/.motd_show_always
  assertFalse "File .motd_show_always still present" "$?"
}

# shellcheck disable=SC1091
source shunit2
