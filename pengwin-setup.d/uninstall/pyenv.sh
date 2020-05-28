#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

line_rgx='^[^#]*\bPATH.*/.pyenv/bin'
line2_rgx='^[^#]*\bpyenv init -'
line3_rgx='^[^#]*\bpyenv virtualenv-init -'

function multiclean_file() {

  if [[ -f "$1" ]]; then
    echo "$1 found! Cleaning..."
    clean_file "$1" "$line_rgx"
    clean_file "$1" "$line2_rgx"
    clean_file "$1" "$line3_rgx"
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
  whiptail --title "pyenv" --msgbox "Please restart your shell, or 'pyenv not found' will continue to be shown with every command issued" 8 85

}

if show_warning "pyenv" "$@"; then
  main "$@"
fi
