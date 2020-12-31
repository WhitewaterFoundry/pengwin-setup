#!/bin/bash

source commons.sh

function testMain() {
  declare WIN_CUR_VER
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup autoinstall GUI GUILIB
 
  for i in 'xclip' 'gnome-themes-standard' 'gtk2-engines-murrine' 'dbus' 'dbus-x11' 'mesa-utils' 'libqt5core5a' 'binutils' 'libnss3' 'libegl1-mesa' ; do
    package_installed $i    
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/bin/xclip
  assertEquals "xclip was not installed" "0" "$?"

  test -f /usr/lib/${dist}-linux-gnu/gtk-2.0/2.10.0/engines/libmurrine.so
  assertEquals "gtk2-engines-murrine was not installed" "0" "$?"

  command -v /usr/bin/dbus-daemon
  assertEquals "dbus was not installed" "0" "$?"

  command -v /usr/bin/dbus-launch
  assertEquals "dbus-x11 was not installed" "0" "$?"

  command -v /usr/bin/glxdemo
  assertEquals "mesa-utils was not installed" "0" "$?"

  test -f /usr/lib/${dist}-linux-gnu/libQt5Core.so.5
  assertEquals "libqt5core5a was not installed" "0" "$?"

  command -v /usr/bin/gold
  assertEquals "binutils was not installed" "0" "$?"

  test -f /usr/lib/${dist}-linux-gnu/libnss3.so
  assertEquals "libnss3 was not installed" "0" "$?"

  test -f /usr/share/bug/libegl1-mesa/control
  assertEquals "libegl1-mesa was not installed" "0" "$?"

  # Our created stuff
  if [[ ${WIN_CUR_VER} -gt 17063 ]]; then
    test -f /etc/dbus-1/session.conf
    assertEquals "/etc/dbus-1/session.conf was not installed" "0" "$?"
  else
    echo "Skip /etc/dbus-1/session.conf testing"
  fi

  #test -f /usr/share/dbus-1/session.conf
  #assertEquals "/usr/share/dbus-1/session.conf was not installed" "0" "$?"

  test -f /etc/profile.d/dbus.sh
  assertEquals "/etc/profile.d/dbus.sh was not installed" "0" "$?"  
}

function testUninstall() {
  declare WIN_CUR_VER
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup autoinstall UNINSTALL GUILIB

  for i in 'xclip' 'gnome-themes-standard' 'gtk2-engines-murrine' 'dbus-x11' ; do
    package_installed $i    
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/xclip
  assertEquals "xclip was not uninstalled" "1" "$?"

  test -f /usr/lib/${dist}-linux-gnu/gtk-2.0/2.10.0/engines/libmurrine.so
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

source shunit2
