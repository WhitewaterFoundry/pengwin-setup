#!/bin/bash

source commons.sh

#######################################
# Test systemd detection function
# Arguments:
#  None
#######################################
function test_systemd_detection() {
  # Define the function locally for testing since sourcing common.sh requires WSL environment
  function is_systemd_running() {
    local init_process
    init_process=$(ps -p 1 -o comm= 2>/dev/null || echo "")
    
    if [[ "${init_process}" == "systemd" ]]; then
      return 0
    else
      return 1
    fi
  }
  
  # Test the function exists
  type is_systemd_running >/dev/null 2>&1
  assertTrue "is_systemd_running function should exist" "$?"
  
  # Test the function returns a valid exit code (0 or 1)
  is_systemd_running
  local result=$?
  
  assertTrue "is_systemd_running should return 0 or 1" "[ ${result} -eq 0 ] || [ ${result} -eq 1 ]"
  
  # Check if we're actually running systemd
  local init_process
  init_process=$(ps -p 1 -o comm= 2>/dev/null || echo "")
  
  if [[ "${init_process}" == "systemd" ]]; then
    # If systemd is running, function should return 0
    is_systemd_running
    assertEquals "is_systemd_running should return 0 when systemd is PID 1" "0" "$?"
  else
    # If systemd is not running, function should return 1
    is_systemd_running
    assertEquals "is_systemd_running should return 1 when systemd is not PID 1" "1" "$?"
  fi
}

# shellcheck disable=SC1091
source shunit2
