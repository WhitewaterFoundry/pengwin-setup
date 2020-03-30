
source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Windows Terminal"

cp -f /usr/local/lib/sudo.ps1 "${wHome}/Pengwin"

if cmd-exe /C tasklist | grep -Fq 'wt.exe' ; then
	echo "Windows Terminal process running. Killing process..."
	cmd-exe /C taskkill /IM 'wt.exe' /F
fi

winterm_full_name="$(winpwsh-exe "(Get-AppxPackage Microsoft.WindowsTerminal).PackageFullName")"
winpwsh-exe "${wHomeWinPath}\\Pengwin\\sudo.ps1" "Remove-AppxPackage -Confirm -Package \"$winterm_full_name\""

}

if show_warning "Windows Terminal" "$@" ; then
	if whiptail --title "!! Windows Terminal !!" --yesno "Make sure you are not running this in Windows Terminal! Otherwise the uninstallation might be incomplete." 8 85 ; then
		main "$@"
	fi
fi