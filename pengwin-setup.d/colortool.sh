#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "COLORTOOL" --yesno "Would you like to install Microsoft's ColorTool for easily changing the Windows console color scheme, along with a setup script for a user-friendly theme setting method? This will be installed to your Windows home directory under .ColorTool" 10 80) then
	echo "Installing ColorTool"
	ColortoolUrl="https://github.com/microsoft/Terminal/releases/download/1904.29002/ColorTool.zip"

	echo "Installing required install dependencies"
	sudo apt-get install -y -q wget unzip

	wColortoolDir="$(cmd-exe /C "echo %USERPROFILE%\.ColorTool" | tr -d '\r')"
	ColortoolDir="$(wslpath "${wColortoolDir}")"
	if [[ ! -d "${ColortoolDir}" ]] ; then
		createtmp

		echo "Downloading ColorTool zip"
		if wget -O colortool.zip "$ColortoolUrl" ; then
		# Download succeeded! Continue rest of script
		echo "Creating ColorTool install directory: $ColortoolDir"
		mkdir -p "${ColortoolDir}"

		echo "Unpacking ColorTool zip"
		unzip colortool.zip -d "${ColortoolDir}"

		echo "Setting ColorTool.exe permissions"
		chmod +x "${ColortoolDir}/ColorTool.exe"

		if (whiptail --title "COLORTOOL" --yesno "Would you like to install a collection of iTerm2 color schemes compatible with Microsoft ColorTool?" 8 80) then
			echo "Installing iTerm themes for ColorTool"
			ColorschemesUrl="https://github.com/mbadolato/iTerm2-Color-Schemes/archive/master.zip"

			echo "Downloading iTerm themes zip"
			if wget -O iterm2-schemes.zip "$ColorschemesUrl" ; then
			# Download succeeded! Continue
			echo "Unpacking iTerm themes zip"
			unzip iterm2-schemes.zip

			echo "Copy iTerm2 schemes to ${ColortoolDir}/schemes"
			cp iTerm2-Color-Schemes-master/schemes/* "${ColortoolDir}/schemes"
			else
			# Download failed
			echo "Download failed. Is your internet connection down? Please try installing again"
			fi
		fi

		echo "Creating colortool script and installing to /usr/local/bin"
		sudo bash -c 'cat > /usr/local/bin/colortool' << EOF
#!/bin/bash

# Initial check
if [[ ! -d "${ColortoolDir}" ]] ; then
	echo "Cannot find ColorTool install directory ${ColortoolDir}"
	echo "Please run pengwin-setup and install ColorTool again"
	exit 0
fi

# Scan ColorTool directory schemes folder
SchemeNames="\$(/bin/ls -1 "${ColortoolDir}/schemes" | grep ".\.itermcolors" | sed 's|\.itermcolors||g')"

# Begin functions
function main() {

# No arguments found
if [[ "\$#" -eq 0 ]] ; then
	echo "No argument[s] provided. Usage: colortool -h|--help"
	return 1
fi

# Handle arguments
case "\$1" in
	-h|--help)
		usage
		return 0
		;;
	-l|--list-themes)
		echo "\$SchemeNames"
		return 0
		;;
	-p|--list-previews)
		"${ColortoolDir}/ColorTool.exe" --xterm --schemes
		echo ""
		return 0
		;;
	-s|--set-theme)
		set_theme "\$2"
		return \$?
		;;
	-r|--reset)
		reset
		return \$?
		;;
	*)
		echo "Unrecognised argument[s]. Usage: colortool -h|--help"
		return 1
		;;
esac

}

function usage() {

# Print usage
echo "Usage: colortool-setup -h|--help"
echo "                       -l|--list-themes"
echo "                       -s|--set-theme "theme_name""

}

function set_theme() {

# Local variable to hold result
# 1 = default = no matching color scheme found
local result=1

# While loop, executed with only the 'echo -e ____' in a subshell
while read line ; do
	if [[ "\$line" == "\$1" ]] ; then
		echo "Setting scheme \$1"
		echo ""
		"${ColortoolDir}/ColorTool.exe" --xterm "\$1.itermcolors"
		result=0

		echo "Ensuring scheme set on each terminal launch..."
		local bashstr="echo '\"${ColortoolDir}/ColorTool.exe\" --quiet --xterm \"\$1.itermcolors\"' > /etc/profile.d/01-colortool.sh"
		if ! sudo bash -c "\$bashstr" ; then
			result=2
		fi
	fi
done <<< "\$(echo -e "\$SchemeNames")"

# Handle end result (exit smoothly if scheme set)
if [[ \$result -eq 1 ]] ; then
	echo "Scheme \$1 not found"
	return 1
elif [[ \$result -eq 2 ]] ; then
	echo "Failed to get root, unable to set color scheme for terminal launch"
	return 1
else
	return 0
fi

}

function reset()
{

if [[ -f "/etc/profile.d/01-colortool.sh" ]] ; then
	if sudo rm -f "/etc/profile.d/01-colortool.sh" ; then
		echo "Reset console theme to default. Please restart shell to see changes"
		return 0
	else
		echo "Failed to get root, unable to remove Pengwin launch config"
		return 1
	fi
else
	echo "No console scheme configured to be set on Pengwin launch"
	echo "If your console is currently themed, please restart the shell to return to default"
	return 1
fi

}

main "\$@"
exit $?
EOF
		sudo chmod +x /usr/local/bin/colortool
		whiptail --title "COLORTOOL" --msgbox "Finished installing. You can view and set installed schemes with 'colortool'" 8 80

		else
		# Download failed
		echo "Download failed. Is your internet connection down? Please try installing again"
		fi

		cleantmp
	else
		echo "${ColortoolDir} already exists, leaving in place."
		echo "To reinstall ColorTool, please delete ${ColortoolDir} and run this installer again"
	fi
else
	echo "Skipping ColorTool"
fi
