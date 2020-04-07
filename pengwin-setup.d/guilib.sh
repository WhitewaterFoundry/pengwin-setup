#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "GUI Libraries" --yesno "Would you like to install a base set of libraries for GUI applications?" 8 75); then
  echo "Installing GUILIB"

  sudo apt-get install -y -q -t testing xclip gnome-themes-standard gtk2-engines-murrine dbus dbus-x11 mesa-utils libqt5core5a binutils libnss3 libegl1-mesa

  if [[ -z ${WSL2} ]]; then
    # If WSL1 we patch libQt5Core.so
    sudo strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5
  fi

  echo "Configuring dbus if you already had it installed. If not, you might see some errors, and that is okay."
  #stretch
  sudo touch /etc/dbus-1/session.conf
  sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /etc/dbus-1/session.conf
  sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /etc/dbus-1/session.conf
  sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /etc/dbus-1/session.conf
  #sid
  sudo touch /usr/share/dbus-1/session.conf
  sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /usr/share/dbus-1/session.conf
  sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /usr/share/dbus-1/session.conf
  sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /usr/share/dbus-1/session.conf

  eval "$(timeout 2s dbus-launch --auto-syntax)"

  sudo tee "/etc/profile.d/dbus.sh" <<EOF
#!/bin/bash

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then

  eval "\$(timeout 2s dbus-launch --auto-syntax)"
fi

EOF

  touch "${HOME}"/.should-restart

else
  echo "Skipping GUILIB"
fi
