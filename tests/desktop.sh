#!/bin/bash
source commons.sh

function test_install_xfce() {

  run_pengwinsetup autoinstall GUI DESKTOP XFCE

  package_installed "xfce4"
  assertTrue "package xfce4 is not installed" "$?"
}

function disable_test_install_mate() {

  run_pengwinsetup autoinstall GUI DESKTOP MATE

  package_installed "mate-desktop-environment"
  assertTrue "package xfce4 is not installed" "$?"
}

source shunit2