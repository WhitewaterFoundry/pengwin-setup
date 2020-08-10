#!/bin/bash

source commons.sh

set -e

run_test ./cpp-vs-clion_test.sh
run_test ./hidpi.sh
run_test ./dotnet.sh
