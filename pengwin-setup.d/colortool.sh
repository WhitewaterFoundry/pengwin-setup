#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "COLORTOOL" --yesno "Would you like to install Microsoft's ColorTool for easily changing the Windows console color scheme, along with a setup script for a user-friendly theme setting method? This will be installed to your Windows home directory under .ColorTool" 10 80) then
	echo "Installing ColorTool"
	ColortoolUrl="https://github.com/Microsoft/console/releases/download/1810.02002/ColorTool.zip"

	echo "Installing required install dependencies"
	sudo apt-get install -y -q wget unzip

	wColortoolDir="$(cmd-exe /C "echo %USERPROFILE%\.ColorTool" | tr -d '\r')"
	ColortoolDir="$(wslpath "${wColortoolDir}")"
	if [[ ! -d "${ColortoolDir}" ]] ; then
		createtmp
		echo "Creating ColorTool install directory: $ColortoolDir"
		mkdir -p "${ColortoolDir}"

		echo "Downloading ColorTool zip"
		wget -O colortool.zip "$ColortoolUrl"

		echo "Unpacking ColorTool zip"
		unzip colortool.zip -d "${ColortoolDir}"

		echo "Setting ColorTool.exe permissions"
		chmod +x "${ColortoolDir}/ColorTool.exe"

		if (whiptail --title "COLORTOOL" --yesno "Would you like to install a collection of iTerm2 color schemes compatible with Microsoft ColorTool?" 8 80) then
			echo "Installing iTerm themes for ColorTool"
			ColorschemesUrl="https://github.com/mbadolato/iTerm2-Color-Schemes/archive/master.zip"

			echo "Downloading iTerm themes zip"
			wget -O iterm2-schemes.zip "$ColorschemesUrl"

			echo "Unpacking iTerm themes zip"
			unzip iterm2-schemes.zip

			echo "Copy iTerm2 schemes to ${ColortoolDir}/schemes"
			cp iTerm2-Color-Schemes-master/schemes/* "${ColortoolDir}/schemes"
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
ColorSchemes="\$(/bin/ls -1 "${ColortoolDir}/schemes" | grep ".\.itermcolors")"
SchemeNames="\$(echo "\${ColorSchemes}" | sed 's|\.itermcolors||g')"

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
	-s|--set-theme)
		set_theme "\$2"
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

# Local function required for piping text as root
function sudo_bash() {

if ! sudo bash -c "\$@" ; then
	result=2
fi

}

# While loop, executed with only the 'echo -e ____' in a subshell
while read line ; do
	if [[ "\$line" == "\$1" ]] ; then
		echo "Setting scheme \$1"
		echo ""
		"${ColortoolDir}/ColorTool.exe" --xterm "\$1"
		result=0

		echo "Ensuring scheme set on each terminal launch..."
		sudo_bash "echo '\"/mnt/c/Users/kim (grufwub)/.ColorTool/ColorTool.exe\" --quiet --xterm \"\$1\"' > /etc/profile.d/01-colortool.sh"
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

main "\$@"
exit $?
EOF
		sudo chmod +x /usr/local/bin/colortool
		whiptail --title "COLORTOOL" --msgbox "Finished installing. You can view and set installed schemes with 'colortool'" 8 80

		cleantmp
	else
		echo "${ColortoolDir} already exists, leaving in place."
		echo "To reinstall ColorTool, please delete ${ColortoolDir} and run this installer again"
	fi
else
	echo "Skipping ColorTool"
fi
