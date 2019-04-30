#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "COLORTOOL" --yesno "Would you like to install Microsoft's ColorTool for easily changing the Windows console color scheme? This will be installed to your Windows home directory under .ColorTool" 8 80) then
	echo "Installing ColorTool"
	ColortoolUrl="https://github.com/Microsoft/console/releases/download/1810.02002/ColorTool.zip"

	echo "Installing required install dependencies"
	sudo apt-get install -y -q wget unzip

	wColortoolDir="$(cmd-exe /C "echo %USERPROFILE%\.ColorTool" | tr -d '\r')"
	ColortoolDir="$(wslpath "${wVcxsrvDir}")"
	if [[ ! -d "${ColortoolDir}" ]] ; then
		createtmp
		echo "Creating ColorTool install directory: $VcxsrvDir"
		mkdir -p "${ColortoolDir}"

		echo "Downloading ColorTool zip"
		wget -O colortool.zip "$ColortoolUrl"

		echo "Unpacking ColorTool zip"
		unzip colortool.zip -d "${ColortoolDir}"

		if (whiptail --title "COLORTOOL" --yesno "Would you like to install a collection of iTerm2 color schemes compatible with Microsoft ColorTool, along with a setup script for a user-friendly theme setting method?" 10 80) then
			echo "Installing iTerm themes for ColorTool"
			ColorschemesUrl="https://github.com/mbadolato/iTerm2-Color-Schemes/archive/master.zip"
			
			echo "Downloading iTerm themes zip"
			wget -O iterm2-schemes.zip "$ColorschemesUrl"

			echo "Unpacking iTerm themes zip"
			unzip iterm2-schemes.zip

			echo "Copy iTerm2 schemes to ${ColortoolDir}/schemes"
			cp schemes/* "${ColortoolDir}/schemes"

			echo "Creating colortool-setup script and installing to /usr/local/bin"
			sudo bash -c 'cat > /usr/local/bin/colortool-setup' << EOF
#!/bin/bash

if [[ ! -d "${ColortoolDir}" ]] ; then
	echo "Cannot find ColorTool install directory ${ColortoolDir}"
	echo "Please run pengwin-setup and install ColorTool again"
	exit 0
fi

ColorSchemes="$(/bin/ls -1 "${ColortoolDir}/schemes" | grep 'itermcolors')"
for scheme in $ColorSchemes ; do
	
done
EOF

			whiptail --title "COLORTOOL" --msgbox "To set "
		fi

		cleantmp
	else
		echo "${ColortoolDir} already exists, leaving in place."
		echo "To reinstall ColorTool, please delete ${ColortoolDir} and run this installer again"
	fi

	if (whiptail --title "VCXSRV" --yesno "Would you like VcXsrv to be started at Pengwin launch? A startup script will be added to /etc/profile.d" 8 80) then
		echo "Configuring VcxSrv to start on Pengwin launch"
		sudo bash -c 'cat > /etc/profile.d/vcxsrv.sh' << EOF
#!/bin/bash
cmd.exe /C "${wVcxsrvDir}\vcxsrv.exe" :0 -silent-dup-error -multiwindow &> /dev/null &
disown
EOF
	fi
else
	echo "Skipping ColorTool"
fi
