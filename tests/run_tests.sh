#!/bin/bash

source commons.sh

set -e

run_test ./update_pengwin.sh

i=0

if [ -z "${CIRCLE_NODE_TOTAL}" ]; then
  run_test ./java.sh
  run_test ./pythonpi.sh
  run_test ./go.sh
  run_test ./ansible.sh
  run_test ./fish.sh
  run_test ./x410.sh
  run_test ./rclocal.sh
  run_test ./cpp-vs-clion_test.sh
  run_test ./jetbrains-support.sh
  run_test ./hidpi.sh
  run_test ./dotnet.sh
  run_test ./brew.sh
  run_test ./guilib.sh
  run_test ./desktop.sh
  run_test ./lamp.sh "10.6"
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then
  run_test ./pythonpi.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then
  run_test ./desktop.sh
  run_test ./lamp.sh "BUILTIN"
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then
  run_test ./fish.sh
  run_test ./x410.sh
  run_test ./rclocal.sh
  run_test ./cpp-vs-clion_test.sh
  run_test ./hidpi.sh
  run_test ./ansible.sh
  run_test ./java.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then
  run_test ./brew.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then
  run_test ./lamp.sh "10.3"
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then
  run_test ./dotnet.sh
  run_test ./guilib.sh
  run_test ./go.sh
  run_test ./jetbrains-support.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then
  run_test ./lamp.sh "10.6"
fi
