#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

version="21.1.16"

if (confirm --title "VCXSRV" --yesno "Would you like to install the VcXsrv X-server? This will be installed to your Windows home directory under .vcxsrv" 8 80); then
  echo "Installing VcXsrv"
  VcxsrvUrl="https://github.com/marchaesen/vcxsrv/releases/download/${version}/vcxsrv-64.${version}.0.installer.noadmin.exe"

  echo "Installing required install dependencies"
  install_packages wget unzip p7zip-full mesa-utils x11-utils

  createtmp

  echo "Downloading VcxSrv installer"
  wget -O vcxsrvinstaller.exe "$VcxsrvUrl"

  wVcxsrvDir="$(cmd-exe /C "echo %USERPROFILE%\.vcxsrv" | tr -d '\r')"
  VcxsrvDir="$(wslpath "${wVcxsrvDir}")"

  if [[ -d "${VcxsrvDir}" ]]; then
    echo "Uninstalling previous version"
    if cmd-exe /C tasklist | grep -Fq 'vcxsrv.exe'; then
      echo "vcxsrv.exe running. Killing process..."
      cmd-exe /C taskkill /IM 'vcxsrv.exe' /F
    fi

    # now safe to delete
    rm -rf "${VcxsrvDir}"
  fi

  echo "Creating vcxsrv install directory: $VcxsrvDir"
  mkdir -p "${VcxsrvDir}"

  echo "Unpacking installer executable"
  mkdir vcxsrv
  7z x vcxsrvinstaller.exe -o"${VcxsrvDir}"

  cleantmp

  echo "Configuring VcxSrv to start on Pengwin launch"
  sudo bash -c 'cat > /etc/profile.d/01-vcxsrv.sh' <<EOF
#!/bin/sh

if ! cmd-exe /C tasklist | grep -Fq 'vcxsrv.exe'; then
  if [ -n "\${WSL2}" ]; then
    (cmd-exe /V /C "set __COMPAT_LAYER=HighDpiAware&& ${wVcxsrvDir}\vcxsrv.exe" :0 -silent-dup-error -multiwindow -nowgl -ac >/dev/null 2>&1 &)
  else
    (cmd-exe /V /C "set __COMPAT_LAYER=HighDpiAware&& ${wVcxsrvDir}\vcxsrv.exe" :0 -silent-dup-error -multiwindow -nowgl >/dev/null 2>&1 &)
  fi
  sleep 1 # Wait for the server to start
fi

export XRANDRDPI=\$(timeout 2s xdpyinfo | grep resolution | sed "s/.*resolution:[ ]*\([0-9]*\)x.*/\1/")
export VCXSRV=yes

EOF

  unset version
  unset VcxsrvUrl
  unset wVcxsrvDir
  unset VcxsrvDir

  #Make sure that DISPLAY points to the gateway IP address
  rm -f "${HOME}/.config/pengwin/display_ip_from_dns"

  # Avoid collision with the other XServer
  sudo rm -f /etc/profile.d/02-x410.sh

  #add_fish_support '01-vcxsrv'
  sudo rm -f "${__fish_sysconf_dir:=/etc/fish/conf.d}/02-x410.fish"

  source /etc/profile.d/01-vcxsrv.sh

  touch "${HOME}"/.should-restart
else
  echo "Skipping VcxSrv"
fi
