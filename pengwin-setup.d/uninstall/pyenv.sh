#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

line_rgx='^[^#]*\bPYENV_ROOT.*/.pyenv'
line2_rgx='^[^#]*\bPATH.*PYENV_ROOT.*/bin'
line3_rgx='^[^#]*\bpyenv init --path'
line4_rgx='^[^#]*\bpyenv init -'
line5_rgx='^[^#]*\bPATH.*/.pyenv/bin'
line6_rgx='^[^#]*\bpyenv virtualenv-init -'


function multiclean_file() {

  if [[ -f "$1" ]]; then
    echo "$1 found! Cleaning..."
    clean_file "$1" "$line_rgx"
    clean_file "$1" "$line2_rgx"
    clean_file "$1" "$line3_rgx"
    clean_file "$1" "$line4_rgx"
    clean_file "$1" "$line5_rgx"
    clean_file "$1" "$line6_rgx"
  fi

}

function main() {

  echo "Uninstalling pyenv"
  local tempPath

  rem_dir "$HOME/.pyenv"

  echo "Removing PATH modifier(s)"
  multiclean_file "$HOME/.bashrc"
  multiclean_file "$HOME/.zshrc"
  multiclean_file "$HOME/.config/fish"

  # Otherwise pyenv leaves a lot of functions / variables set in the environment
  # which only get cleared after a shell restart. Ensures we don't have issues
  # if multiple applications are set to be installed
  echo "Cleaning up shell"
  unset 'PROMPT_COMMAND'
  tempPath=$(echo "$PATH" | sed 's|:|\n|g' | grep -v 'pyenv')
  export PATH="$(echo $tempPath | sed 's| |:|g')"
  unset -f 'pyenv'
  unset -f '_pyenv'
  unset -v '_pyenv_virtualenv_hook'

  echo "Showing user shell-restart warning"
  message --title "pyenv" --msgbox "Please restart your shell, or 'pyenv not found' will continue to be shown with every command issued" 8 85

  touch "${HOME}"/.should-restart
}

if show_warning "pyenv" "$@"; then
  main "$@"
fi
