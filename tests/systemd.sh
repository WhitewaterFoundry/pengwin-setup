#!/bin/bash

source commons.sh

function test_systemd_1() {
  #Remove [boot] if it is already present
  sudo sed -i 's/^\[boot\]$//' /etc/wsl.conf

  run_pengwinsetup install SERVICES SYSTEMD

  assertEquals "[boot] section is not there" "1" "$(grep -c -E "^\[boot\]$" /etc/wsl.conf)"
  assertEquals "SystemD was not enabled" "1" "$(grep -c -E "^systemd.*=.*true$" /etc/wsl.conf)"
}

function test_systemd_2() {
  #Test the case when [boot] is already present
  run_pengwinsetup uninstall SYSTEMD

  run_pengwinsetup install SERVICES SYSTEMD
  assertEquals "[boot] section is not there" "1" "$(grep -c -E "^\[boot\]$" /etc/wsl.conf)"
  assertEquals "SystemD was not enabled" "1" "$(grep -c -E "^systemd.*=.*true$" /etc/wsl.conf)"
}

function test_systemd_3() {
  #Test the case when systemd=false is already present
  sudo sed -i 's$\(systemd=\)\(.*\)$\1false$' /etc/wsl.conf

  run_pengwinsetup install SERVICES SYSTEMD
  assertEquals "[boot] section is not there" "1" "$(grep -c -E "^\[boot\]$" /etc/wsl.conf)"
  assertEquals "SystemD was not enabled" "1" "$(grep -c -E "^systemd.*=.*true$" /etc/wsl.conf)"
}


function test_uninstall() {

  run_pengwinsetup uninstall SYSTEMD

  assertEquals "SystemD was not disabled" "0" "$(grep -c -E "^systemd.*=.*true$" /etc/wsl.conf)"
}

# shellcheck disable=SC1091
source shunit2
