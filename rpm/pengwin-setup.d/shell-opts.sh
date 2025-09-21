#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

function input_rc() {
  echo "Installing optimised inputrc commands to /etc/inputrc"

  if [[ ! -f "/etc/inputrc" ]]; then
    sudo touch /etc/inputrc
  fi

  PENGWIN_STRING="### PENGWIN OPTIMISED DEFAULTS"

  # shellcheck disable=SC2002
  cat /etc/inputrc | while read -r line; do
    if [[ $line == *"${PENGWIN_STRING}"* ]]; then
      return 1
    fi
  done

  if [[ $? == 1 ]]; then
    # While loop found previous customizations
    echo "Previous Pengwin inputrc customizations detected. Cancelling install..."
    message --title "Warning!" --msgbox "Previous install of Pengwin inputrc customizations detected. To reinstall, please edit \"/etc/inputrc\" with your favourite text editor and remove all of the text between (and including) the lines ${PENGWIN_STRING}" 10 95
    return
  fi

  echo "Ensuring that bash-completion is installed"
  sudo mkdir -p /etc/bash_completion.d
  sudo apt-get -y -q install bash-completion

  sudo tee -a /etc/inputrc <<EOF
${PENGWIN_STRING}
# Don't ring bell on completion
set bell-style none

# Filename completion/expansion
set completion-ignore-case on
set show-all-if-ambiguous on
set show-all-if-unmodified on

# Append / to all dirnames
set mark-directories on

# Mark symlinked directories
set mark-symlinked-directories On

# Do not match hidden files
set match-hidden-files off

# Color files by type
set colored-stats On
# Append char to indicate type
set visible-stats On
# Color the common prefix
set colored-completion-prefix On
# Color the common prefix in menu-complete
set menu-complete-display-prefix On

"\e[A": history-search-backward
"\e[B": history-search-forward

\$if Bash
  # Magic Space
  # Insert a space character then performs
  # a history expansion in the line
  Space: magic-space
\$endif
${PENGWIN_STRING}

EOF

  message --title "Further customizations" --msgbox "To make further customizations you may either edit the global inputrc preferences under \"/etc/inputrc\", or for user-specific preferences edit \"~/.inputrc\" with the text editor of your choice. \n\nPlease close and re-open Pengwin" 13 95
}

if (confirm --title "Inputrc Customizations" --yesno "Would you like to install readline optimizations to the global inputrc (\"/etc/inputrc\")? \n\nPlease bear in mind that while bash reads this script on start, other shells like zsh and fish do not." 11 95); then
  input_rc
fi
