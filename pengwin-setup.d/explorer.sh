#!/bin/bash

source $(dirname "$0")/common.sh "$@"


function install_explorer() {

  local exec_name='pengwin.exe'
  echo "WSL executable name: ${exec_name}"
  local plain_name='Pengwin'

  # I know we should use plain_name instead of Pengwin below but for some reason the icon will only work with Pengwin hard-coded

  if (confirm --title "EXPLORER" --yesno "Would you like to enable Windows Explorer shell integration?" 8 65); then
      echo "Enabling Windows Explorer shell integration."
      createtmp
      mkdir $(wslpath "$(powershell.exe -NoProfile -NonInteractive -Command "Write-Output \$Env:USERPROFILE" | tr -d '\r')")/.pengwin
      cp /usr/local/lib/pengwin.ico $(wslpath "$(powershell.exe -NoProfile -NonInteractive -Command "Write-Output \$Env:USERPROFILE" | tr -d '\r')")/.pengwin/pengwin.ico
      cat << EOF >> Install.reg
Windows Registry Editor Version 5.00
[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\Pengwin]
@="Open with Pengwin"
"Icon"="%USERPROFILE%\\.pengwin\\pengwin.ico"
[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\Pengwin\command]
@="_PengwinPath_ run \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && \$(getent passwd \$LOGNAME | cut -d: -f7)\\""
"Icon"="%USERPROFILE%\\.pengwin\\pengwin.ico"
[HKEY_CURRENT_USER\Software\Classes\Directory\shell\\Pengwin]
@="Open with Pengwin"
"Icon"="%USERPROFILE%\\.pengwin\\pengwin.ico"
[HKEY_CURRENT_USER\Software\Classes\Directory\shell\\Pengwin\command]
@="_PengwinPath_ run \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && \$(getent passwd \$LOGNAME | cut -d: -f7)\\""
"Icon"="%USERPROFILE%\\.pengwin\\pengwin.ico"
EOF

      local fullexec=$(wslpath -m "$(which ${exec_name})" | sed 's$/$\\\\\\\\$g')
      sed -i "s/_${plain_name}Path_/${fullexec}/g" Install.reg
      cp Install.reg $(wslpath "$(powershell.exe -NoProfile -NonInteractive -Command "Write-Output \$Env:TEMP" | tr -d '\r')")/Install.reg
      cmd.exe /C "Reg import %TEMP%\Install.reg"

      cleantmp
   else
      echo "Disabling Windows Explorer shell integration."
      createtmp

      cat << EOF >> Uninstall.reg
Windows Registry Editor Version 5.00
[-HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plain_name}]
[-HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plain_name}]
EOF
      cp Uninstall.reg $(wslpath "$(powershell.exe -NoProfile -NonInteractive -Command "Write-Output \$Env:TEMP" | tr -d '\r')")/Uninstall.reg
      cmd.exe /C "Reg import %TEMP%\Uninstall.reg"

      cleantmp
  fi
}

function upgrade_explorer() {

  local plain_name='WLinux'

  createtmp

  cat << EOF >> Uninstall.reg
Windows Registry Editor Version 5.00
[-HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plain_name}]
[-HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plain_name}]
EOF
  cp Uninstall.reg $(wslpath "$(powershell.exe -NoProfile -NonInteractive -Command "Write-Output \$Env:TEMP" | tr -d '\r')")/Uninstall.reg
  cmd.exe /C "Reg import %TEMP%\Uninstall.reg"

  cleantmp

  SkipConfirmations=1

  install_explorer
}

function main() {

  if [[ $# -gt 0 && "$1" == "--upgrade" ]]; then

    cmd.exe /C "Reg query HKEY_CURRENT_USER\Software\Classes\Directory\shell\\WLinux"

    if [[ $? == 0 ]]; then

      upgrade_explorer
    fi

  else
    install_explorer
  fi

}

main "$@"
