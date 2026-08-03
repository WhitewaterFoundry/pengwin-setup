#!/bin/bash

source commons.sh

function setup_shell_configs() {
  run mkdir -p "${HOME}/.config/fish"
  run touch "${HOME}/.bashrc" "${HOME}/.zshrc" "${HOME}/.config/fish/config.fish"
}

function test_main() {
  setup_shell_configs
  run_pengwinsetup install TOOLS OHMYPOSH

  assertTrue "oh-my-posh binary not found" "[ -f ${HOME}/.local/bin/oh-my-posh ]"
  assertTrue "oh-my-posh binary not executable" "[ -x ${HOME}/.local/bin/oh-my-posh ]"
  run "${HOME}/.local/bin/oh-my-posh" --version
  assertEquals "oh-my-posh version command failed" "0" "$?"
  assertEquals "bash init was not configured" "1" "$(run grep -c -F 'eval "$($HOME/.local/bin/oh-my-posh init bash)"' "${HOME}/.bashrc")"
  assertEquals "zsh init was not configured" "1" "$(run grep -c -F 'eval "$($HOME/.local/bin/oh-my-posh init zsh)"' "${HOME}/.zshrc")"
  assertEquals "fish init was not configured" "1" "$(run grep -c -F '$HOME/.local/bin/oh-my-posh init fish | source' "${HOME}/.config/fish/config.fish")"
}

function test_uninstall() {
  setup_shell_configs
  run_pengwinsetup install TOOLS OHMYPOSH
  run_pengwinsetup install UNINSTALL OHMYPOSH

  assertFalse "oh-my-posh binary still exists" "[ -f ${HOME}/.local/bin/oh-my-posh ]"
  assertEquals "bash init was not removed" "0" "$(run grep -c -F 'eval "$($HOME/.local/bin/oh-my-posh init bash)"' "${HOME}/.bashrc")"
  assertEquals "zsh init was not removed" "0" "$(run grep -c -F 'eval "$($HOME/.local/bin/oh-my-posh init zsh)"' "${HOME}/.zshrc")"
  assertEquals "fish init was not removed" "0" "$(run grep -c -F '$HOME/.local/bin/oh-my-posh init fish | source' "${HOME}/.config/fish/config.fish")"
}

# shellcheck disable=SC1091
source shunit2
