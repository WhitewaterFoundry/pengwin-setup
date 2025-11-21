#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install SERVICES WSL-HELLO-SUDO

  # Check if PAM module was installed
  if [[ -f /lib/x86_64-linux-gnu/security/pam_wsl_hello.so ]] || [[ -f /usr/local/lib/pam_wsl_hello.so ]]; then
    assertTrue "PAM module was installed" "0"
  else
    assertTrue "PAM module was not installed" "1"
  fi

  # Check if PAM configuration was updated
  if [[ -f /etc/pam.d/sudo ]]; then
    grep -q "pam_wsl_hello" /etc/pam.d/sudo
    assertTrue "PAM configuration was updated" "$?"
  fi
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL WSL-HELLO-SUDO

  # Check if PAM configuration was cleaned
  if [[ -f /etc/pam.d/sudo ]]; then
    grep -q "pam_wsl_hello" /etc/pam.d/sudo
    assertFalse "PAM configuration was not cleaned" "$?"
  fi

  # Check if PAM module was removed
  assertFalse "PAM module x86_64 was removed" "[ -f /lib/x86_64-linux-gnu/security/pam_wsl_hello.so ]"
  assertFalse "PAM module local was removed" "[ -f /usr/local/lib/pam_wsl_hello.so ]"
  assertFalse "PAM module lib security was removed" "[ -f /lib/security/pam_wsl_hello.so ]"

  # Check for leftover files that should be removed
  assertFalse "PAM config leftover was removed" "[ -f /usr/share/pam-configs/wsl-hello ]"
  assertFalse "Config directory leftover was removed" "[ -d /etc/pam_wsl_hello ]"
  assertFalse "Saved uninstall script was removed" "[ -d /usr/local/share/wsl-hello-sudo ]"
}

# shellcheck disable=SC1091
source shunit2
