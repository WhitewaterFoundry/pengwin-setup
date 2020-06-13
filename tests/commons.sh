#!/bin/bash

function package_installed() {

  # shellcheck disable=SC2155
  local result=$(apt -qq list $1 2>/dev/null | grep -c "\[")

  if [[ $result == 0 ]]; then
    return 1
  else
    return 0
  fi
}

