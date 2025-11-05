#!/bin/bash

source commons.sh

set -e

run_test ./update_pengwin.sh

i=0

if [ -z "${CIRCLE_NODE_TOTAL}" ]; then
  run_test ./java.sh
  run_test ./pythonpi.sh
  run_test ./go.sh
  run_test ./ruby.sh
  #run_test ./ansible.sh
  run_test ./nodejs_n.sh
  run_test ./fish.sh
  run_test ./x410.sh
  run_test ./rclocal.sh
  run_test ./dotnet.sh
  run_test ./microsoft_edit.sh
  run_test ./desktop.sh
  run_test ./terraform.sh
  run_test ./awscli.sh
  run_test ./motd_settings.sh
  run_test ./kubernetes.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #0
  run_test ./nodejs_nvm.sh
  run_test ./motd_settings.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #1
  run_test ./desktop.sh
  run_test ./lamp.sh "BUILTIN"
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #2
  run_test ./x410.sh
  run_test ./rclocal.sh
  run_test ./cpp-vs-clion_test.sh
  run_test ./hidpi.sh
  run_test ./ansible.sh
  run_test ./synaptic.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #3
  run_test ./terraform.sh
  run_test ./awscli.sh
  run_test ./nodejs_lts.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #4
  run_test ./nodejs_n.sh
  #run_test ./lamp.sh "10.11"
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #5
  run_test ./dotnet.sh
  #run_test ./guilib.sh
  run_test ./jetbrains-support.sh
  run_test ./pythonpi-poetry.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #6
  #run_test ./lamp.sh "10.9"
  run_test ./brew.sh
  run_test ./powershell.sh
  run_test ./nodejs_latest.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #7
  run_test ./pythonpi.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #8
  run_test ./java.sh
  run_test ./microsoft_edit.sh
elif [[ ${CIRCLE_NODE_INDEX} == $((i++)) ]]; then #9
  run_test ./kubernetes.sh
  run_test ./go.sh
  run_test ./fish.sh
fi
