#!/bin/bash

if (whiptail --title "VCXSRV" --yesno "Would you like to install the VcXsrv X-server? This will be installed to your Windows home directory under .vcxsrv" 8 80) then
	echo "Installing VcXsrv"
	createtmp
	local VcxsrvUrl="https://sourceforge.net/projects/vcxsrv/files/vcxsrv/1.20.1.4/vcxsrv-64.1.20.1.4.installer.exe/download"
	
	echo "Installing required install dependencies"
	sudo apt-get install -y -q wget unzip p7zip-full

	local wVcxsrvDir="$(cmd-exe /C "echo %USERPROFILE%\.vcxsrv" | tr -d '\r')"
	local VcxsrvDir="$(wslpath "${wVcxsrvDir}")"
	if [[ ! -d "" ]] ; then
		echo "Creating vcxsrv install directory: $VcxsrvDir"
		mkdir -p "${VcxsrvDir}"

		echo "Downloading VcxSrv installer"
		wget -O vcxsrvinstaller.exe "${VcxsrvUrl}"

		echo "Unpacking installer executable"
		7z x vcxsrvinstaller.exe -o"${VcxsrvDir}"
	else
		echo "${VcxsrvDir} already exists, leaving in place."
	fi

	if (whiptail --title "VCXSRV" --yesno "Would you like VcXsrv to be started at first Pengwin launch? A startup script will be added to /etc/profile.d." 8 80) then
		echo "Configuring VcxSrv to start on Pengwin launch"
		sudo bash -c 'cat > /etc/profile.d/vcxsrv.sh' << EOF
#!/bin/bash
cmd-exe /C "${wVcxsrvDir}\vcxsrv.exe" :0 -silent-dup-error -multiwindow &> /dev/null &
disown
EOF
	fi
else
	echo "Skipping VcxSrv"
fi
