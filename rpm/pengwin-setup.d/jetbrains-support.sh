#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir

function install_jetbrains_support() {

  install_packages rsync zip

  # shellcheck disable=SC2155
  local appdata_path="$(wslpath -u "$(wslvar APPDATA)")"
  local jetbrains_path="${appdata_path}/JetBrains"

  if [[ -d "${jetbrains_path}" ]]; then
    local options_folder_list=${jetbrains_path}/"*/options"

    for options_folder in ${options_folder_list}; do

      if [[ -f "${options_folder}/wsl.distributions.xml" ]]; then
        local reg_exp='\(<microsoft-id>\)Pengwin\(</microsoft-id>\)'

        for line in ${options_folder}/"wsl.distributions.xml"; do
          if (grep -q ${reg_exp} <"${line}"); then
            sed -i "s#${reg_exp}#\1WLinux\2#" "${line}"
          fi
        done
      else
        cp "${SetupDir}/template-wsl.distributions.xml" "${options_folder}/wsl.distributions.xml"
      fi
    done
  fi
}

if (confirm --title "JetBrains support" --yesno "Would you like to install support to JetBrains tools?" 8 52); then
  install_jetbrains_support
else
  echo "Skipping Jetbrains support"
fi
