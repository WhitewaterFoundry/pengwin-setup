#!/bin/bash

source "$(dirname "$0")/common.sh" "$@"

declare SetupDir

function install_jetbrains_support() {

  install_packages rsync zip
  
  APPDATA_PATH="$(wslpath -u "$(wslvar APPDATA)")"
  JETBRAINS_PATH="$APPDATA_PATH/JetBrains"
  if [[ -d "$JETBRAINS_PATH" ]]; then
    OPTIONS_FOLDER_LIST=$JETBRAINS_PATH/"*/options"
    for OPTIONS_FOLDER in $OPTIONS_FOLDER_LIST; do
      if [[ -f "$OPTIONS_FOLDER/wsl.distributions.xml" ]]; then
        reg_exp='\(<microsoft-id>\)Pengwin\(</microsoft-id>\)'
        for line in $OPTIONS_FOLDER/"wsl.distributions.xml"; do
          if (grep -q ${reg_exp} <"${line}"); then
            sed -i "s#${reg_exp}#\1WLinux\2#" "${line}"
          fi
        done
      else
        cp "$SetupDir/template-wsl.distributions.xml" "$OPTIONS_FOLDER/wsl.distributions.xml"
      fi
    done
  fi
}

if (confirm --title "JetBrains support" --yesno "Would you like to install support to JetBrains tools?" 8 52); then
  install_jetbrains_support
else
  echo "Skipping Jetbrains support"
fi
