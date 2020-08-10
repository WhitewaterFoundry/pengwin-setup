#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "VCXSRV" --yesno "Would you like to install the VcXsrv X-server? This will be installed to your Windows home directory under .vcxsrv" 8 80); then
  echo "Installing VcXsrv"
  VcxsrvUrl="https://sourceforge.net/projects/vcxsrv/files/vcxsrv/1.20.8.1/vcxsrv-64.1.20.8.1.installer.exe/download"

  echo "Installing required install dependencies"
  install_packages wget unzip p7zip-full mesa-utils

  wVcxsrvDir="$(cmd-exe /C "echo %USERPROFILE%\.vcxsrv" | tr -d '\r')"
  VcxsrvDir="$(wslpath "${wVcxsrvDir}")"
  if [[ ! -d "${VcxsrvDir}" ]]; then
    createtmp
    echo "Creating vcxsrv install directory: $VcxsrvDir"
    mkdir -p "${VcxsrvDir}"

    echo "Downloading VcxSrv installer"
    wget -O vcxsrvinstaller.exe "$VcxsrvUrl"

    echo "Unpacking installer executable"
    mkdir vcxsrv
    7z x vcxsrvinstaller.exe -o"${VcxsrvDir}"

    sudo apt-get remove -y -q p7zip-full
    sudo apt-get autoremove -y

    cleantmp
  else
    echo "${VcxsrvDir} already exists, leaving in place."
    echo "To reinstall VcXsrv, please delete ${VcxsrvDir} and run this installer again"
  fi

  echo "Configuring VcxSrv to start on Pengwin launch"
  sudo bash -c 'cat > /etc/profile.d/01-vcxsrv.sh' <<EOF
#!/bin/bash

if [[ -n \${WSL2} ]]; then
  (cmd.exe /C "${wVcxsrvDir}\vcxsrv.exe" :0 -silent-dup-error -multiwindow -nowgl -ac &> /dev/null &)
else
  (cmd.exe /C "${wVcxsrvDir}\vcxsrv.exe" :0 -silent-dup-error -multiwindow -nowgl &> /dev/null &)
fi
EOF

  # Avoid collision with the other XServer
  sudo rm -f /etc/profile.d/02-x410.sh
  touch "${HOME}"/.should-restart
else
  echo "Skipping VcxSrv"
fi
