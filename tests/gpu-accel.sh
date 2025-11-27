#!/bin/bash

source commons.sh

#######################################
# Test disabling GPU acceleration
# Arguments:
#  None
#######################################
function test_gpu_disable() {
  run_pengwinsetup install GUI GPU GPU_ACCEL_DISABLE

  run test -f /etc/profile.d/disable-gpu-accel.sh
  assertTrue "File disable-gpu-accel.sh not created" "$?"

  run test -f /etc/fish/conf.d/disable-gpu-accel.fish
  assertTrue "File disable-gpu-accel.fish not created" "$?"
}

#######################################
# Test enabling GPU acceleration (removes the disable config)
# Arguments:
#  None
#######################################
function test_gpu_enable() {
  # First disable to create the files
  run_pengwinsetup install GUI GPU GPU_ACCEL_DISABLE

  # Then enable to remove them
  run_pengwinsetup install GUI GPU GPU_ACCEL_ENABLE

  run test -f /etc/profile.d/disable-gpu-accel.sh
  assertFalse "File disable-gpu-accel.sh still present after enable" "$?"
}

#######################################
# Test uninstalling GPU acceleration settings
# Arguments:
#  None
#######################################
function test_uninstall() {
  # First disable to create the files
  run_pengwinsetup install GUI GPU GPU_ACCEL_DISABLE

  # Then uninstall
  run_pengwinsetup install UNINSTALL GPU

  run test -f /etc/profile.d/disable-gpu-accel.sh
  assertFalse "File disable-gpu-accel.sh still present after uninstall" "$?"

  run test -f /etc/fish/conf.d/disable-gpu-accel.fish
  assertFalse "File disable-gpu-accel.fish still present after uninstall" "$?"
}

# shellcheck disable=SC1091
source shunit2
