#!/bin/bash

source commons.sh

function testPengwinSetupUpdate() {
  run_pengwinsetup update --noninteractive
}

# shellcheck disable=SC1091
source shunit2
