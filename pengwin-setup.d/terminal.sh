source $(dirname "$0")/common.sh "$@"

function main() {

  local menu_choice=$(

    menu --title "Terminal Menu" --checklist --separate-output "Select the terminals you want to install\n[SPACE to select, ENTER to confirm]:" 14 60 7 \
      "WINTERM" "Windows Terminal" off \
      "WSLTTY" "WSLtty" off \
      "TILIX" "Tilix (requires X Server)" off \
      "GTERM" "Gnome Terminal (requires X Server)" off \
      "XFTERM" "Xfce Terminal (requires X Server)" off \
      "TERMIN" "Terminator (requires X Server)" off \
      "KONSO" "Konsole (requires X Server)" off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"WINTERM"* ]] ; then
    echo "WINTERM"
    if (confirm --title "Windows Terminal" --yesno "Would you like to install Windows Terminal?" 8 40) ; then
      tmp_win_version=$(wslsys -B -s)
      if [ $tmp_win_version -lt 18362 ]; then
        whiptail --title "Unsupported Windows 10 Build" --msgbox "Windows Terminal requires Windows 10 Build 18362, but you are using $tmp_win_version. Skipping Windows Terminal." 8 56
        return
      fi

      if (whiptail --title "Windows Terminal" --yes-button "Store" --no-button "GitHub" --yesno "Would you like to install the store version or GitHub version?" 8 80) then
        wslview "ms-windows-store://pdp/?ProductId=9n0dx20hk701"
      else
        createtmp

        winterminal_url="$(curl -s https://api.github.com/repos/microsoft/terminal/releases | grep 'browser_' | head -1 | cut -d\" -f4)"
        wget --progress=dot "$winterminal_url" -O "WindowsTerminal.msixbundle" 2>&1 | sed -un 's/.* \([0-9]\+\)% .*/\1/p' | whiptail --title "Windows Terminal" --gauge "Downloading Windows Terminal..." 7 50 0

        [ -d "${wHome}/Pengwin/tmp" ] || mkdir -p "${wHome}/Pengwin/tmp"
        cp "WindowsTerminal.msixbundle" "${wHome}/Pengwin/tmp"
        cp -f /usr/local/lib/sudo.ps1 "${wHome}/Pengwin"

        winpwsh-exe "${wHomeWinPath}\\Pengwin\\sudo.ps1" "Add-AppxPackage -Path \"${wHomeWinPath}\\Pengwin\\tmp\\WindowsTerminal.msixbundle\""

        rm -rf "${wHome}/Pengwin/tmp/WindowsTerminal.msixbundle"
        cleantmp
      fi
    else
      echo "Skipping Windows Terminal"
    fi
  fi

  if [[ ${menu_choice} == *"WSLTTY"* ]] ; then
    echo "WSLTTY"
    if (confirm --title "WSLtty" --yesno "Would you like to install WSLtty?" 8 40) ; then
      createtmp
      [ -d "${wHome}/Pengwin/.wsltty" ] || mkdir -p "${wHome}/Pengwin/.wsltty"

      wsltty_url="$(curl -s https://api.github.com/repos/mintty/wsltty/releases | grep 'browser_' | head -1 | cut -d\" -f4)"
      wget --progress=dot "$wsltty_url" -O "wsltty.7z" 2>&1 | sed -un 's/.* \([0-9]\+\)% .*/\1/p' | whiptail --title "WSLtty" --gauge "Downloading WSLtty..." 7 50 0

      7z x wsltty.7z -o${wHome}/Pengwin/.wsltty/
      echo "Installing WSLtty.... Please wait patiently"
      tmp_f="$(pwd)"
      cd "${wHome}/Pengwin/.wsltty"
      cmd.exe /C "install.bat"
      cd "$tmp_f"
      unset tmp_f

      whiptail --title "WSLtty" --msgbox "Installation complete. You can find the shortcuts in your start menu.\nNote: use the Terminal unisntall to uninstall cleanly" 8 56
    else
      echo "Skipping WSLtty"
    fi
  fi

  if [[ ${menu_choice} == *"TILIX"* ]] ; then
    echo "TILIX"
    if (confirm --title "Tilix" --yesno "Would you like to install Tilix?" 8 40) ; then
      sudo debconf-apt-progress -- apt-get install tilix libsecret-1-0 -y
      whiptail --title "Tilix" --msgbox "Installation complete. You can start it by running $ tilix" 8 56

      INSTALLED=true
    else
      echo "skipping TILIX"
    fi
  fi

  if [[ ${menu_choice} == *"GTERM"* ]] ; then
    if (confirm --title "GNOME Terminal" --yesno "Would you like to install GNOME Terminal?" 8 40) ; then
      echo "GTERM"
      sudo debconf-apt-progress -- apt-get install gnome-terminal -y
      whiptail --title "GNOME Terminal" --msgbox "Installation complete. You can start it by running $ gnome-terminal" 8 56

      INSTALLED=true
    else
      echo "skipping GTERM"
    fi
  fi

  if [[ ${menu_choice} == *"XFTERM"* ]] ; then
    echo "XFTERM"
    if (confirm --title "Xfce Terminal" --yesno "Would you like to install Xfce Terminal?" 8 40) ; then
      sudo debconf-apt-progress -- apt-get install xfce4-terminal -y
      whiptail --title "Xfce Terminal" --msgbox "Installation complete. You can start it by running $ xfce4-terminal" 8 56

      INSTALLED=true
    else
      echo "Skipping XFTERM"
  fi

  if [[ ${menu_choice} == *"TERMIN"* ]] ; then
    echo "TERMIN"
    if (confirm --title "Terminator" --yesno "Would you like to install Terminator?" 8 40) ; then
      sudo debconf-apt-progress -- apt-get install dbus-x11 terminator -y
      whiptail --title "Terminator" --msgbox "Installation complete. You can start it by running $ terminator" 8 56

      INSTALLED=true
    else
      echo "Skipping TERMIN"
  fi

  if [[ ${menu_choice} == *"KONSO"* ]] ; then
    echo "KONSO"
    if (confirm --title "Konsole" --yesno "Would you like to install Konsole?" 8 40) ; then
      sudo debconf-apt-progress -- apt-get install dbus-x11 konsole -y
      whiptail --title "Konsole" --msgbox "Installation complete. You can start it by running $ konsole" 8 56

      INSTALLED=true
    else
      echo "Skipping KONSO"
  fi

  if [[ "${INSTALLED}" == true ]] ; then
    bash "${SetupDir}"/shortcut.sh --yes "$@"
  fi

}

main "$@"