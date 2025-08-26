#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS CLOUDCLI KUBERNETES

  command -v /usr/local/bin/helm
  assertEquals "helm was not installed" "0" "$?"
  run /usr/local/bin/helm version
  assertEquals "helm was not installed" "1" "$(run /usr/local/bin/helm version | grep -c 'v3')"

  command -v /usr/bin/kubectl
  assertEquals "kubectl was not installed" "0" "$?"
  run /usr/bin/kubectl version
  assertEquals "kubectl was not installed" "1" "$(run /usr/bin/kubectl version | grep -c 'v1.33')"

  command -v /usr/local/bin/kubectx
  assertEquals "kubectx was not installed" "0" "$?"

  command -v /usr/local/bin/kubens
  assertEquals "kubens was not installed" "0" "$?"
}

function test_uninstall() {
  run_pengwinsetup uninstall KUBERNETES

  command -v /usr/bin/kubectl
  assertEquals "kubectl was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
