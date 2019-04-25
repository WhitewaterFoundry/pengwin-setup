#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "VCXSRV" --yesno "Would you like to install the VcXsrv X-server? This will be installed to your Windows home directory under .vcxsrv" 8 80) then
	echo "Installing VcXsrv"
	VcxsrvUrl="https://sourceforge.net/projects/vcxsrv/files/vcxsrv/1.20.1.4/vcxsrv-64.1.20.1.4.installer.exe/download"

	echo "Installing required install dependencies"
	sudo apt-get install -y -q wget unzip p7zip-full

	wVcxsrvDir="$(cmd-exe /C "echo %USERPROFILE%\.vcxsrv" | tr -d '\r')"
	VcxsrvDir="$(wslpath "${wVcxsrvDir}")"
	if [[ ! -d "" ]] ; then
		createtmp
		echo "Creating vcxsrv install directory: $VcxsrvDir"
		mkdir -p "${VcxsrvDir}"

		echo "Downloading VcxSrv installer"
		wget -O vcxsrvinstaller.exe "$VcxsrvUrl"

		echo "Unpacking installer executable"
		mkdir vcxsrv
		7z x vcxsrvinstaller.exe -o"${VcxsrvDir}"
		# cp -r vcxsrv/* "${VcxsrvDir}"

		cleantmp
	else
		echo "${VcxsrvDir} already exists, leaving in place."
		echo "To reinstall VcXsrv, please delete ${VcxsrvDir} and run this installer again"
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
	echo "Skipping VcxSrv"
fi
