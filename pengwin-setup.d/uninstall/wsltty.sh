
source $(dirname "$0")/uninstall-common.sh

wsltty_base_dir="${wHome}/Pengwin/.wsltty"
wsltty_dir="$(wslpath "$(wslvar -s LOCALAPPDATA)")/wsltty"
wsltty_config_dir="$(wslpath "$(wslvar -s APPDATA)")/wsltty"
function main()
{

echo "Uninstalling WSLtty"

if cmd-exe /C tasklist | grep -Fq 'wslbridge2.exe' ; then
	echo "WSLtty processes running. Killing process..."
	cmd-exe /C taskkill /IM 'cygwin-console-helper.exe' /F
	cmd-exe /C taskkill /IM 'mintty.exe' /F
	cmd-exe /C taskkill /IM 'wslbridge2.exe' /F
fi

echo "Removing directory: $wsltty_base_dir"
if [[ -d "$wsltty_base_dir" ]] ; then
	echo "Running unsintall script"
	tmp_f="$(pwd)"
	cd "$wsltty_base_dir"
	cmd.exe /C "uninstall.bat"
	cd "$tmp_f"
	unset tmp_f

    rm -rf "$wsltty_base_dir"
else
	echo "... not found!"
fi

rem_dir "$wsltty_dir"
rem_dir "$wsltty_config_dir"

}

if show_warning "WSLtty" "$@" ; then
	main "$@"
fi