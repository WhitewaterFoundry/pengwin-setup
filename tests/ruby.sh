#!/bin/bash

source commons.sh

function test_ruby() {
  run_pengwinsetup install PROGRAMMING RUBY --debug

  assertTrue "FILE PROFILE-RUBY" "[ -f /etc/profile.d/ruby.sh ]"
  assertTrue "FILE FISH-RUBY" "[ -f /etc/fish/conf.d/ruby.fish ]"

  local installed_script="/etc/profile.d/ruby.sh"
  # shellcheck disable=SC1090
  source "${installed_script}"

  command -v ruby
  assertEquals "Ruby was not installed" "0" "$?"

  command -v rbenv
  assertEquals "rbenv was not installed" "0" "$?"

  assertEquals "Ruby 4.0.1 was not installed" "1" "$(ruby -v | grep -c '4.0.1')"

  command -v bundle
  assertEquals "bundle was not installed" "0" "$?"

  shellcheck "${installed_script}"
  assertEquals "shellcheck reported errors on ${installed_script}" "0" "$?"
}

function test_uninstall() {

  run_pengwinsetup install UNINSTALL RUBY --debug

  assertFalse "FILE PROFILE-RUBY" "[ -f /etc/profile.d/ruby.sh ]"
  assertFalse "FILE FISH-RUBY" "[ -f /etc/fish/conf.d/ruby.fish ]"

  command -v ruby
  assertEquals "Ruby was not uninstalled" "1" "$?"

  command -v rbenv
  assertEquals "rbenv was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
