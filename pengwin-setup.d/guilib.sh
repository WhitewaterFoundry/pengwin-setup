#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

declare WIN_CUR_VER

if (confirm --title "GUI Libraries" --yesno "Would you like to install a base set of libraries for GUI applications?" 8 75); then
  echo "Installing GUILIB"

  install_packages xclip gtk2-engines-murrine dbus dbus-x11 mesa-utils libqt5core5t64 binutils libnss3 libegl1 libegl-mesa0

  if [[ -z ${WSL2} ]]; then
    # If WSL1 we patch libQt5Core.so
    sudo strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5
  fi

  echo "Configuring dbus if you already had it installed. If not, you might see some errors, and that is okay."
  if [[ ${WIN_CUR_VER} -gt 17063 ]]; then
    sudo rm -f /etc/dbus-1/session.conf
    sudo sed -i 's$<listen>.*</listen>$<listen>unix:tmpdir=/tmp</listen>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$<auth>ANONYMOUS</auth>$<auth>EXTERNAL</auth>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$<allow_anonymous/></busconfig>$</busconfig>$' /usr/share/dbus-1/session.conf
  else
    sudo touch /usr/share/dbus-1/session.conf
    sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /usr/share/dbus-1/session.conf
  fi

  sudo tee "/etc/profile.d/dbus.sh" <<EOF
#!/bin/sh

setup_dbus() {
  # if dbus-launch is installed, then load it
  if ! (command -v dbus-launch >/dev/null); then
    return
  fi

  # Enabled via systemd
  if [ -n "\${DBUS_SESSION_BUS_ADDRESS}" ]; then
    return
  fi

  # Use a per-user directory for storing the D-Bus environment
  dbus_env_dir="\${XDG_RUNTIME_DIR:-${HOME}/.cache}"
  mkdir -p "\${dbus_env_dir}" 2>/dev/null || true

  dbus_pid="\$(pidof -s dbus-daemon)"

  if [ -z "\${dbus_pid}" ]; then
    dbus_env="\$(timeout 2s dbus-launch --auto-syntax)" || return

    # Extract and export only the expected variables from dbus-launch output
    DBUS_SESSION_BUS_ADDRESS="\$(printf '%s\n' "\${dbus_env}" | sed -n "s/^DBUS_SESSION_BUS_ADDRESS='\(.*\)';\\$/\1/p")"
    DBUS_SESSION_BUS_PID="\$(printf '%s\n' "\${dbus_env}" | sed -n "s/^DBUS_SESSION_BUS_PID=\([0-9][0-9]*\);$/\1/p")"

    if [ -n "\${DBUS_SESSION_BUS_ADDRESS}" ] && [ -n "\${DBUS_SESSION_BUS_PID}" ]; then
      export DBUS_SESSION_BUS_ADDRESS
      export DBUS_SESSION_BUS_PID

      dbus_env_file="\${dbus_env_dir}/dbus_env_\${DBUS_SESSION_BUS_PID}"
      {
        echo "DBUS_SESSION_BUS_ADDRESS='\${DBUS_SESSION_BUS_ADDRESS}'"
        echo "DBUS_SESSION_BUS_PID='\${DBUS_SESSION_BUS_PID}'"
      } >"\${dbus_env_file}"
      chmod 600 "\${dbus_env_file}" 2>/dev/null || true
    fi

    unset dbus_env
  else
    # Reuse existing dbus session
    dbus_env_file="\${dbus_env_dir}/dbus_env_\${dbus_pid}"
    if [ -f "\${dbus_env_file}" ]; then
      DBUS_SESSION_BUS_ADDRESS="\$(sed -n "s/^DBUS_SESSION_BUS_ADDRESS='\(.*\)'\$/\1/p" "\${dbus_env_file}")"
      DBUS_SESSION_BUS_PID="\$(sed -n "s/^DBUS_SESSION_BUS_PID='\([0-9][0-9]*\)'\$/\1/p" "\${dbus_env_file}")"
      if [ -n "\${DBUS_SESSION_BUS_ADDRESS}" ] && [ -n "\${DBUS_SESSION_BUS_PID}" ]; then
        export DBUS_SESSION_BUS_ADDRESS
        export DBUS_SESSION_BUS_PID
      fi
    fi
  fi

  unset dbus_pid
  unset dbus_env_file
  unset dbus_env_dir
}

if [ -z "\$SYSTEMD_PID" ] && [ -z "\${DBUS_SESSION_BUS_ADDRESS}" ]; then
  setup_dbus
fi

EOF

  source /etc/profile.d/dbus.sh

  sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"

  sudo tee "${__fish_sysconf_dir}/dbus.fish" <<EOF
#!/bin/fish

# Check if we have Windows Path
if command -q cmd.exe

  for line in (timeout 2s dbus-launch | string match '*=*')
    set -l kv (string split -m 1 = -- \$line )
    set -gx \$kv[1] (string trim -c '\\'"' -- \$kv[2])
  end
end

EOF

  touch "${HOME}"/.should-restart

else
  echo "Skipping GUILIB"
fi
