#!/bin/bash

source $(dirname "$0")/common.sh "$@"


function install_explorer() {

  local exec_name='pengwin.exe'
  echo "WSL executable name: ${exec_name}"
  local plain_name='Pengwin'

  if (confirm --title "EXPLORER" --yesno "Would you like to enable Windows Explorer shell integration?" 8 65); then
      echo "Enabling Windows Explorer shell integration."
      createtmp

      cat << EOF >> Install.reg
Windows Registry Editor Version 5.00
[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\Pengwin]
@="Open with Pengwin"
"Icon"="_IcoPath_"
[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\Pengwin\command]
@="_PengwinPath_ run \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && login_shell\\""
[HKEY_CURRENT_USER\Software\Classes\Directory\shell\Pengwin]
@="Open with Pengwin"
"Icon"="_IcoPath_"
[HKEY_CURRENT_USER\Software\Classes\Directory\shell\Pengwin\command]
@="_PengwinPath_ run \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && login_shell\\""
EOF

      local fullexec=$(wslpath -m "$(which ${exec_name})" | sed 's$/$\\\\\\\\$g')
      local icopath=$(cmd-exe /C "echo '%USERPROFILE%\\AppData\\Local\\Packages\\WhitewaterFoundryLtd.Co.16571368D6CFF_kd1vv0z0vy70w\\LocalState\\rootfs\\usr\\local\\lib\\pengwin.ico'" | tr -d '\r' | sed 's$\\$\\\\\\\\$g')
      icopath=$(echo $icopath | tr -d "\'")
      sed -i "s/_${plain_name}Path_/${fullexec}/g" Install.reg
      sed -i "s/_IcoPath_/${icopath}/g" Install.reg
      cp Install.reg $(wslpath "$(cmd-exe /c 'echo %TEMP%' | tr -d '\r')")/Install.reg
      cmd-exe /C "Reg import %TEMP%\Install.reg"

      cleantmp
   else
      echo "Disabling Windows Explorer shell integration."
      createtmp

      cat << EOF >> Uninstall.reg
Windows Registry Editor Version 5.00
[-HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plain_name}]
[-HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plain_name}]
EOF
      cp Uninstall.reg $(wslpath "$(cmd-exe /c 'echo %TEMP%' | tr -d '\r')")/Uninstall.reg
      cmd-exe /C "Reg import %TEMP%\Uninstall.reg"

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
  cp Uninstall.reg $(wslpath "$(cmd-exe /c 'echo %TEMP%' | tr -d '\r')")/Uninstall.reg
  cmd-exe /C "Reg import %TEMP%\Uninstall.reg"

  cleantmp

  SkipConfirmations=1

  install_explorer
}

function main() {

  if [[ $# -gt 0 && "$1" == "--upgrade" ]]; then

    local exit_code_1
    local exit_code_2

    cmd-exe /C "Reg query HKEY_CURRENT_USER\Software\Classes\Directory\shell\\WLinux"
    exit_code_1=$?

    cmd-exe /C "Reg query HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\WLinux"
    exit_code_2=$?

    if [[ ${exit_code_1} == 0 || ${exit_code_2} == 0 ]]; then

      upgrade_explorer
    fi

  else
    install_explorer
  fi

}

main "$@"
