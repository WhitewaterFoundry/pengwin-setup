#!/bin/bash

source commons.sh

function testMain() {
  declare WIN_CUR_VER
  # shellcheck disable=SC2155
  local dist="$(uname -m)"

  run_pengwinsetup install GUI GUILIB

  for i in 'xclip' 'gtk2-engines-murrine' 'dbus' 'dbus-x11' 'mesa-utils' 'libnss3' 'libegl1' 'libegl-mesa0' ; do
    package_installed  "$i"
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/bin/xclip
  assertEquals "xclip was not installed" "0" "$?"

  test -f /usr/lib/"${dist}"-linux-gnu/gtk-2.0/2.10.0/engines/libmurrine.so
  assertEquals "gtk2-engines-murrine was not installed" "0" "$?"

  command -v /usr/bin/dbus-daemon
  assertEquals "dbus was not installed" "0" "$?"

  command -v /usr/bin/dbus-launch
  assertEquals "dbus-x11 was not installed" "0" "$?"

  command -v /usr/bin/glxdemo
  assertEquals "mesa-utils was not installed" "0" "$?"

  test -f /usr/lib/"${dist}"-linux-gnu/libQt5Core.so.5
  assertEquals "libqt5core5t64 was not installed" "0" "$?"

  test -f /usr/lib/"${dist}"-linux-gnu/libnss3.so
  assertEquals "libnss3 was not installed" "0" "$?"

  # Our created stuff
  if [[ ${WIN_CUR_VER} -gt 17063 ]]; then
    test -f /etc/dbus-1/session.conf
    assertEquals "/etc/dbus-1/session.conf was not installed" "0" "$?"
  else
    echo "Skip /etc/dbus-1/session.conf testing"
  fi

  #test -f /usr/share/dbus-1/session.conf
  #assertEquals "/usr/share/dbus-1/session.conf was not installed" "0" "$?"

  check_script '/etc/profile.d/dbus.sh'
}

function testUninstall() {
  declare WIN_CUR_VER
  # shellcheck disable=SC2155
  local dist="$(uname -m)"

  run_pengwinsetup install UNINSTALL GUILIB

  for i in 'xclip' 'dbus-x11' ; do
    package_installed "$i"
    assertFalse "package $i is not uninstalled" "$?"
  done

  test -f /usr/lib/"${dist}"-linux-gnu/gtk-2.0/2.10.0/engines/libmurrine.so
  assertEquals "gtk2-engines-murrine was not uninstalled" "1" "$?"

  command -v /usr/bin/dbus-launch
  assertEquals "dbus-x11 was not uninstalled" "1" "$?"

  # Our created stuff
  if [[ ${WIN_CUR_VER} -gt 17063 ]]; then
    test -f /etc/dbus-1/session.conf
    assertEquals "/etc/dbus-1/session.conf was not uninstalled" "1" "$?"
  else
    echo "Skip /etc/dbus-1/session.conf testing"
  fi

  #test -f /usr/share/dbus-1/session.conf
  #assertEquals "/usr/share/dbus-1/session.conf was not installed" "1" "$?"

  test -f /etc/profile.d/dbus.sh
  assertEquals "/etc/profile.d/dbus.sh was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
