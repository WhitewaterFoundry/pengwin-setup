
source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Windows Terminal"

cp -f /usr/local/lib/sudo.ps1 "${wHome}/Pengwin"

winterm_full_name="$(winpwsh-exe "(Get-AppxPackage Microsoft.WindowsTerminal).PackageFullName")"
winpwsh-exe "${wHomeWinPath}\\Pengwin\\sudo.ps1" "Remove-AppxPackage -Confirm -Package \"$winterm_full_name\""

}

if show_warning "Windows Terminal" "$@" ; then
	main "$@"
fi