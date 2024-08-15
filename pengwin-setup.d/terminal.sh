#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

declare wHome
declare SetupDir

function main() {

  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Terminal Menu" --menu "Select the terminals you want to install\n[ENTER to confirm]:" 16 60 7 \
      "WINTERM" "Windows Terminal" \
      "WSLTTY" "WSLtty" \
      "TILIX" "Tilix${REQUIRES_X}" \
      "GTERM" "Gnome Terminal${REQUIRES_X}" \
      "XFTERM" "Xfce Terminal${REQUIRES_X}" \
      "TERMINATOR" "Terminator${REQUIRES_X}" \
      "KONSO" "Konsole${REQUIRES_X}"

    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"WINTERM"* ]]; then
    echo "WINTERM"
    if (confirm --title "Windows Terminal" --yesno "Would you like to install Windows Terminal?" 8 40); then
      tmp_win_version=$(wslsys -B -s)
      if [ "$tmp_win_version" -lt 18362 ]; then
        message --title "Unsupported Windows 10 Build" --msgbox "Windows Terminal requires Windows 10 Build 18362, but you are using $tmp_win_version. Skipping Windows Terminal." 8 56
        return
      fi

      wslview "ms-windows-store://pdp/?ProductId=9n0dx20hk701&mode=mini"
    else
      echo "Skipping Windows Terminal"
    fi
  fi

  if [[ ${menu_choice} == *"WSLTTY"* ]]; then
    echo "WSLTTY"
    if (confirm --title "WSLtty" --yesno "Would you like to install WSLtty?" 8 40); then
      createtmp

      echo "Installing required install dependencies"
      install_packages wget p7zip-full

      [ -d "${wHome}/Pengwin/.wsltty" ] || mkdir -p "${wHome}/Pengwin/.wsltty"

      wsltty_url="$(curl -s https://api.github.com/repos/mintty/wsltty/releases | grep 'browser_' | head -1 | cut -d\" -f4)"
      wget --progress=dot "$wsltty_url" -O "wsltty.7z" 2>&1 | sed -un 's/.* \([0-9]\+\)% .*/\1/p' | whiptail --title "WSLtty" --gauge "Downloading WSLtty..." 7 50 0

      7z x wsltty.7z -o"${wHome}"/Pengwin/.wsltty/
      echo "Installing WSLtty.... Please wait patiently"
      tmp_f="$(pwd)"
      # shellcheck disable=SC2164
      cd "${wHome}/Pengwin/.wsltty"
      cmd-exe /C "install.bat"
      # shellcheck disable=SC2164
      cd "$tmp_f"
      unset tmp_f

      message --title "WSLtty" --msgbox "Installation complete. You can find the shortcuts in your start menu.\nNote: use the Terminal unisntall to uninstall cleanly" 8 56
    else
      echo "Skipping WSLtty"
    fi
  fi

  if [[ ${menu_choice} == *"TILIX"* ]]; then
    echo "TILIX"
    if (confirm --title "Tilix" --yesno "Would you like to install Tilix?" 8 40); then
      install_packages tilix libsecret-1-0
      message --title "Tilix" --msgbox "Installation complete. You can start it by running $ tilix" 8 56

      INSTALLED=true
    else
      echo "skipping TILIX"
    fi
  fi

  if [[ ${menu_choice} == *"GTERM"* ]]; then
    echo "GTERM"
    if (confirm --title "GNOME Terminal" --yesno "Would you like to install GNOME Terminal?" 8 40); then
      echo "Install dependencies..."
      bash "${SetupDir}"/guilib.sh --yes "$@"

      install_packages gnome-terminal
      message --title "GNOME Terminal" --msgbox "Installation complete. You can start it by running $ gnome-terminal" 8 56

      INSTALLED=true
    else
      echo "skipping GTERM"
    fi
  fi

  if [[ ${menu_choice} == *"XFTERM"* ]]; then
    echo "XFTERM"
    if (confirm --title "Xfce Terminal" --yesno "Would you like to install Xfce Terminal?" 8 40); then
      install_packages xfce4-terminal
      message --title "Xfce Terminal" --msgbox "Installation complete. You can start it by running $ xfce4-terminal" 8 56

      INSTALLED=true
    else
      echo "Skipping XFTERM"
    fi
  fi

  if [[ ${menu_choice} == *"TERMINATOR"* ]]; then
    echo "TERMINATOR"
    if (confirm --title "Terminator" --yesno "Would you like to install Terminator?" 8 40); then
      echo "Install dependencies..."
      bash "${SetupDir}"/guilib.sh --yes "$@"
      install_packages terminator
      message --title "Terminator" --msgbox "Installation complete. You can start it by running $ terminator" 8 56

      INSTALLED=true
    else
      echo "Skipping TERMINATOR"
    fi
  fi

  if [[ ${menu_choice} == *"KONSO"* ]]; then
    echo "KONSO"
    if (confirm --title "Konsole" --yesno "Would you like to install Konsole?" 8 40); then
      echo "Install dependencies..."
      bash "${SetupDir}"/guilib.sh --yes "$@"
      install_packages konsole breeze

      sudo tee "/etc/profile.d/kde.sh" <<EOF
#!/bin/bash

export QT_STYLE_OVERRIDE=Breeze

EOF

      message --title "Konsole" --msgbox "Installation complete.\n\nYou can start it by running: $ konsole" 10 56

      INSTALLED=true
    else
      echo "Skipping KONSO"
    fi
  fi

  if [[ "${INSTALLED}" == true ]]; then
    bash "${SetupDir}"/shortcut.sh --yes "$@"
  fi

}

main "$@"
