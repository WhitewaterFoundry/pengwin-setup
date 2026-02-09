#!/bin/bash

source commons.sh

HISTORY_FILE="/home/${TEST_USER}/.config/pengwin/install-history.txt"

#######################################
# Test that install history is recorded after a successful install
# Arguments:
#  None
#######################################
function test_install_history_recorded() {
  # Clean up any existing history
  run rm -f "${HISTORY_FILE}"

  # Run an install that records history
  run_pengwinsetup install SETTINGS MOTD MOTD_NEVER

  run test -f "${HISTORY_FILE}"
  assertTrue "Install history file was not created" "$?"

  local content
  content=$(run cat "${HISTORY_FILE}")
  echo "History content: ${content}"
  assertEquals "Install history entry not recorded" "SETTINGS MOTD MOTD_NEVER" "${content}"
}

#######################################
# Test that duplicate entries are not added
# Arguments:
#  None
#######################################
function test_install_history_no_duplicates() {
  # Clean up any existing history
  run rm -f "${HISTORY_FILE}"

  # Run the same install twice
  run_pengwinsetup install SETTINGS MOTD MOTD_NEVER
  run_pengwinsetup install SETTINGS MOTD MOTD_NEVER

  local line_count
  line_count=$(run grep -cF '' "${HISTORY_FILE}")
  assertEquals "Duplicate entry was added to install history" "1" "${line_count}"
}

#######################################
# Test that different entries are both recorded
# Arguments:
#  None
#######################################
function test_install_history_multiple_entries() {
  # Clean up any existing history
  run rm -f "${HISTORY_FILE}"

  run_pengwinsetup install SETTINGS MOTD MOTD_NEVER
  run_pengwinsetup install SETTINGS MOTD MOTD_ALWAYS

  local line_count
  line_count=$(run grep -cF '' "${HISTORY_FILE}")
  assertEquals "Multiple entries not recorded" "2" "${line_count}"
}

# shellcheck disable=SC1091
source shunit2
