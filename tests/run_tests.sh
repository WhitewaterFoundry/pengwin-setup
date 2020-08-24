#!/bin/bash

source commons.sh

set -e

run_pengwinsetup --noninteractive update

run_test ./x410.sh
run_test ./rclocal.sh
run_test ./cpp-vs-clion_test.sh
run_test ./hidpi.sh
run_test ./dotnet.sh
