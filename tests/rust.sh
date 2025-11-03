#!/bin/bash

source commons.sh

function testMain() {
  run_pengwinsetup autoinstall PROGRAMMING RUST

  assertTrue "FILE PROFILE-RUST" "[ -f /etc/profile.d/rust.sh ]"
  assertTrue "FILE FISH-RUST" "[ -f /etc/fish/conf.d/rust.sh ]"

  local installed_script="/etc/profile.d/rust.sh"
  # shellcheck disable=SC1090
  source ${installed_script}

  command -v rustc
  assertEquals "rustc was not installed" "0" "$?"

  command -v cargo
  assertEquals "cargo was not installed" "0" "$?"

  command -v rustup
  assertEquals "rustup was not installed" "0" "$?"

  assertTrue "CARGO-DIR" "[ -d /home/${TEST_USER}/.cargo ]"
  assertTrue "RUSTUP-DIR" "[ -d /home/${TEST_USER}/.rustup ]"

  shellcheck "${installed_script}"
  assertEquals "shellcheck reported errors on ${installed_script}" "0" "$?"
}

function testUninstall() {
  run_pengwinsetup autoinstall UNINSTALL RUST

  assertFalse "FILE PROFILE-RUST" "[ -f /etc/profile.d/rust.sh ]"
  assertFalse "FILE FISH-RUST" "[ -f /etc/fish/conf.d/rust.sh ]"

  command -v rustc
  assertEquals "rustc was not uninstalled" "1" "$?"

  command -v cargo
  assertEquals "cargo was not uninstalled" "1" "$?"

  command -v rustup
  assertEquals "rustup was not uninstalled" "1" "$?"

  assertFalse "CARGO-DIR" "[ -d /home/${TEST_USER}/.cargo ]"
  assertFalse "RUSTUP-DIR" "[ -d /home/${TEST_USER}/.rustup ]"
}

# shellcheck disable=SC1091
source shunit2
