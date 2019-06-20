#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

plain_name='Pengwin'

function main()
{

echo "Uninstalling Pengwin explorering integration"

createtmp

cat << EOF >> Uninstall.reg
Windows Registry Editor Version 5.00
[-HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plain_name}]
[-HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plain_name}]
EOF

cp Uninstall.reg $(wslpath "$(cmd-exe /c 'echo %TEMP%' | tr -d '\r')")/Uninstall.reg
cmd-exe /C "Reg import %TEMP%\Uninstall.reg"

cleantmp

}

if show_warning "explorer integration" "$@" ; then
	main "$@"
fi
