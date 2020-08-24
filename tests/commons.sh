#!/bin/bash

function oneTimeSetUp() {
  export PATH="$(pwd)/stubs:${PATH}"
  export HOME="${SHUNIT_TMPDIR}/home"
  mkdir -p "${HOME}"
  export SHUNIT_TMPDIR
}

function package_installed() {

  # shellcheck disable=SC2155
  local result=$(apt -qq list $1 2>/dev/null | grep -c "\[")

  if [[ $result == 0 ]]; then
    return 1
  else
    return 0
  fi
}

function run_test() {
  echo "********************************************************************"
  echo "$@"
  "$@"
}

function run_pengwinsetup() {

  local last_param="${!#}"

  if [[ ${last_param} == "--debug" ]]; then
    ../pengwin-setup "$@"
  else
    ../pengwin-setup "$@" > /dev/null 2>&1
  fi
}
