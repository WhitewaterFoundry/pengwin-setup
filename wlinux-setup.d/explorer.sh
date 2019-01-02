#!/bin/bash

source "/etc/wlinux-setup.d/common.sh"

if (whiptail --title "EXPLORER" --yesno "Would you like to enable Windows Explorer shell integration?" 8 65); then
    echo "Enabling Windows Explorer shell integration."
    createtmp
    cat << 'EOF' >> Install.reg
    Windows Registry Editor Version 5.00
    [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\WLinux]
    @="Open with WLinux"
    [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\WLinux\command]
    @="_wlinuxPath_ run \"cd \\\"$(wslpath \\\"%V\\\")\\\" && $(getent passwd $LOGNAME | cut -d: -f7)\""
    [HKEY_CURRENT_USER\Software\Classes\Directory\shell\WLinux]
    @="Open with WLinux"
    [HKEY_CURRENT_USER\Software\Classes\Directory\shell\WLinux\command]
    @="_wlinuxPath_ run \"cd \\\"$(wslpath \\\"%V\\\")\\\" && $(getent passwd $LOGNAME | cut -d: -f7)\""
EOF
    wlinuxPath=$(wslpath -m "$(whereis wlinux.exe | cut --delimiter=' ' -f2)" | sed 's$/$\\\\\\\\$g')
    sed -i "s/_wlinuxPath_/${wlinuxPath}/g" Install.reg
    cp Install.reg $(wslpath "$(cmd.exe /c 'echo %TEMP%' 2>&1 | tr -d '\r')")/Install.reg
    cmd.exe /C "Reg import %TEMP%\Install.reg"
    cleantmp
 else
    echo "Disabling Windows Explorer shell integration."
    createtmp
    cat << 'EOF' >> Uninstall.reg
    Windows Registry Editor Version 5.00
    [-HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\WLinux]
    [-HKEY_CURRENT_USER\Software\Classes\Directory\shell\WLinux]
EOF
    cp Uninstall.reg $(wslpath "$(cmd.exe /c 'echo %TEMP%' 2>&1 | tr -d '\r')")/Uninstall.reg
    cmd.exe /C "Reg import %TEMP%\Uninstall.reg"
    cleantmp
fi
