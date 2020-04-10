#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

vcxsrv_dir="$wHome/.vcxsrv"

function main() {

  echo "Uninstalling VcxSrv"

  echo "Removing $vcxsrv_dir"
  if [[ -d "$vcxsrv_dir" ]]; then
    if cmd-exe /C tasklist | grep -Fq 'vcxsrv.exe'; then
      echo "vcxsrv.exe running. Killing process..."
      cmd-exe /C taskkill /IM 'vcxsrv.exe' /F
    fi

    # now safe to delete
    rm -rf "$vcxsrv_dir"
  else
    echo "... not found!"
  fi

  echo "Removing PATH modifier..."
  sudo_rem_file "/etc/profile.d/01-vcxsrv.sh"

}

if show_warning "vcxsrv" "$@"; then
  main "$@"
fi
