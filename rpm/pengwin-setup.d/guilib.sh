#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

declare WIN_CUR_VER

if (confirm --title "GUI Libraries" --yesno "Would you like to install a base set of libraries for GUI applications?" 8 75); then
  echo "Installing GUILIB"

  install_packages xclip adwaita-gtk2-theme gtk-murrine-engine dbus dbus-x11 glx-utils qt5-qtbase binutils nss mesa-libEGL

  # TODO: Is this already needed?
  if [[ -z ${WSL2} ]]; then
    # If WSL1 we patch libQt5Core.so
    sudo strip --remove-section=.note.ABI-tag /usr/lib64/libQt5Core.so.5
  fi

  echo "Configuring dbus if you already had it installed. If not, you might see some errors, and that is okay."
  if [[ ${WIN_CUR_VER} -gt 17063 ]]; then
    sudo rm /etc/dbus-1/session.conf
    sudo sed -i 's$<listen>.*</listen>$<listen>unix:tmpdir=/tmp</listen>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$<auth>ANONYMOUS</auth>$<auth>EXTERNAL</auth>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$<allow_anonymous/></busconfig>$</busconfig>$' /usr/share/dbus-1/session.conf
  else
    sudo touch /usr/share/dbus-1/session.conf
    sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /usr/share/dbus-1/session.conf
  fi

  eval "$(timeout 2s dbus-launch --auto-syntax)"

  sudo tee "/etc/profile.d/dbus.sh" <<EOF
#!/bin/sh

# Check if we have Windows Path
if ( command -v cmd.exe >/dev/null ); then

  eval "\$(timeout 2s dbus-launch --auto-syntax)"
fi

EOF

  add_fish_support 'dbus'

  touch "${HOME}"/.should-restart

else
  echo "Skipping GUILIB"
fi
