#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir

#######################################
# description
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function enable_rclocal() {

  if (confirm --title "rc.local" --yesno "Would you like to enable rc.local support for running scripts at Pengwin launch?" 10 60); then
    echo "Enabling rc.local..."

    if [[ ! -f /etc/rc.local ]]; then
      sudo tee "/etc/rc.local" <<EOF
#!/bin/sh -e
#
# rc.local
#

if test -d /etc/boot.d ; then
  run-parts /etc/boot.d
fi

EOF
      sudo chmod +x /etc/rc.local
    fi

    # If systemd is running, enable rc-local service
    if is_systemd_running; then
      # Create rc-local.service if it doesn't exist
      if [[ ! -f /etc/systemd/system/rc-local.service ]]; then
        sudo tee "/etc/systemd/system/rc-local.service" <<EOF
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOF
      fi
      sudo systemctl daemon-reload
      sudo systemctl enable rc-local.service
    fi

    local cmd="/bin/bash /etc/rc.local"
    echo "%sudo   ALL=NOPASSWD: ${cmd}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/rclocal

    local profile_rclocal="/etc/profile.d/rclocal.sh"
    sudo tee "${profile_rclocal}" <<EOF
#!/bin/sh

# Check if we have Windows Path
if ( command -v cmd.exe >/dev/null ); then

  # Check if systemd is running
  if [ "\$(ps -p 1 -o comm= 2>/dev/null)" = "systemd" ]; then
    # With systemd, rc.local runs on boot via systemd service
    # Only run manually if the service didn't start properly
    if ! systemctl is-active --quiet rc-local.service 2>/dev/null; then
      sudo ${cmd}
    fi
  else
    # Traditional init, always run the script
    sudo ${cmd}
  fi
fi

EOF
    sudo mkdir -p /etc/boot.d

  else
    echo "Skipping rc.local"

    return 1
  fi

}

#######################################
# description
# Globals:
#   NON_INTERACTIVE
#   sshd_status
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function enable_ssh() {

  if (confirm --title "SSH Server" --yesno "Would you like to enable SSH Server?" 10 60); then

    echo "Enabling SSH Server..."

    local port

    if [[ -z "${NON_INTERACTIVE}" ]]; then
      port=$(${DIALOG_COMMAND} --title "Enter the desired SSH Port" --inputbox "SSH Port: " 8 50 "2222" 3>&1 1>&2 2>&3)
      if [[ -z ${port} ]]; then
        echo "Cancelled"
        return 1
      fi
    else
      port="2222"
    fi

    local address

    if [[ -z "${NON_INTERACTIVE}" ]]; then
      address=$(${DIALOG_COMMAND} --title "Enter the desired Listen Address" --inputbox "Listen Address: " 8 50 "127.0.0.1" 3>&1 1>&2 2>&3)
      if [[ -z ${address} ]]; then
        echo "Cancelled"
        return 1
      fi
    else
      address='127.0.0.1'
    fi

    local sshd_file=/etc/ssh/sshd_config

    sudo cp ${sshd_file} "${sshd_file}.$(date '+%Y-%m-%d_%H-%M-%S').back"

    sudo sed -i '/^# configured by Pengwin/ d' ${sshd_file}
    sudo sed -i '/^ListenAddress/ d' ${sshd_file}
    sudo sed -i '/^Port/ d' ${sshd_file}
    sudo sed -i '/^UsePrivilegeSeparation/ d' ${sshd_file}
    sudo sed -i '/^PasswordAuthentication/ d' ${sshd_file}
    echo "# configured by Pengwin" | sudo tee -a ${sshd_file}
    echo "ListenAddress ${address}" | sudo tee -a ${sshd_file}
    echo "Port ${port}" | sudo tee -a ${sshd_file}
    echo "UsePrivilegeSeparation no" | sudo tee -a ${sshd_file}
    echo "PasswordAuthentication yes" | sudo tee -a ${sshd_file}

    # Enable and start ssh based on init system
    if is_systemd_running; then
      echo "Systemd detected, enabling ssh service"
      sudo systemctl enable --now ssh
      
      # Restart to apply new configuration
      sudo systemctl restart ssh
      
      sshd_status=$(systemctl is-active ssh)
      if [[ $sshd_status != "active" ]]; then
        sudo systemctl restart ssh >/dev/null 2>&1
      fi
    else
      sudo service ssh --full-restart

      sshd_status=$(service ssh status)
      if [[ $sshd_status = *"is not running"* ]]; then
        sudo service ssh --full-restart >/dev/null 2>&1
      fi
    fi

    local startSsh="/usr/bin/start-ssh"
    sudo tee "${startSsh}" <<EOF
#!/bin/bash

# Check if systemd is running (PID 1)
if [ "\$(ps -p 1 -o comm= 2>/dev/null)" = "systemd" ]; then
  # Using systemd - check and start service if not active
  if ! systemctl is-active --quiet ssh; then
    systemctl restart ssh > /dev/null 2>&1
  fi
else
  # Using traditional init - use service command
  sshd_status=\$(service ssh status)
  if [[ \${sshd_status} = *"is not running"* ]]; then
    service ssh --full-restart > /dev/null 2>&1
  fi
fi

EOF

    sudo chmod 700 "${startSsh}"

    echo "%sudo   ALL=NOPASSWD: ${startSsh}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/start-ssh

    local profile_startssh="/etc/profile.d/start-ssh.sh"
    sudo tee "${profile_startssh}" <<EOF
#!/bin/sh

# Check if we have Windows Path
if ( command -v cmd.exe >/dev/null ); then

  # Check if systemd is running
  if [ "\$(ps -p 1 -o comm= 2>/dev/null)" = "systemd" ]; then
    # Service managed by systemd, only start if not already active
    if ! systemctl is-active --quiet ssh; then
      sudo ${startSsh}
    fi
  else
    # Traditional init, always run the start script
    sudo ${startSsh}
  fi
fi

EOF

  else
    echo "Skipping SSH Server"
  fi

}

#######################################
# Enables the SystemD support in the wsl.conf file
# Arguments:
#  None
# Returns:
#   1 If the user cancels the operation
#######################################
function enable_systemd() {

  if [[ -z "${WSL2}" ]]; then
    message --title "SystemD" --msgbox "SystemD is only available in WSL2\n\nIf you want to start services in WSL1 you can use the \"service\" or the \"wslsystemctl\" commands." 11 60
    return 0
  fi

  if (confirm --title "SystemD" --yesno "Would you like to enable SystemD support for this distro?" 10 60); then
    echo "Enabling SystemD..."

    local wsl_conf="/etc/wsl.conf"

    # shellcheck disable=SC2155
    local systemd_exists=$(grep -c -E "^systemd.*=.*$" "${wsl_conf}")
    if [[ ${systemd_exists} -eq 0 ]]; then

      # shellcheck disable=SC2155
      local boot_section_exists=$(grep -c "\[boot\]" "${wsl_conf}")
      if [[ ${boot_section_exists} -eq 0 ]]; then
        echo -e "\n[boot]" | sudo tee -a "${wsl_conf}"
      fi

      sudo sed -i 's/\[boot\]/\0\nsystemd=true/' "${wsl_conf}"
    else
      sudo sed -i 's/^systemd.*=.*$/systemd=true/' "${wsl_conf}"
    fi

    touch "${HOME}"/.should-restart
  else
    echo "Skipping SystemD"

    return 1
  fi

}

#######################################
# description
# Globals:
#   SetupDir
# Arguments:
#  None
# Returns:
#   1 ...
#   <unknown> ...
#######################################
function main() {

  if [[ "$1" == "--enable-ssh" ]]; then
    enable_ssh

    return
  fi

  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(

    menu --title "Services Menu" "${DIALOG_TYPE}" "Enables various services\n[ENTER to confirm]:" 14 70 6 \
      "CASSANDRA" "Install the NoSQL server Cassandra from Apache " ${OFF} \
      "KEYCHAIN" "Install Keychain, the OpenSSH key manager" ${OFF} \
      "LAMP" "Install LAMP Stack" ${OFF} \
      "RCLOCAL" "Enable running scripts at startup from rc.local " ${OFF} \
      "SSH" "Enable SSH server" ${OFF} \
      "SYSTEMD" "Enable SystemD support" ${OFF}

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"CASSANDRA"* ]]; then
    echo "CASSANDRA"
    bash "${SetupDir}"/cassandra.sh "$@"
  fi

  if [[ ${menu_choice} == *"KEYCHAIN"* ]]; then
    echo "KEYCHAIN"
    bash "${SetupDir}"/keychain.sh "$@"
  fi

  if [[ ${menu_choice} == *"LAMP"* ]]; then
    echo "LAMP"
    bash "${SetupDir}"/lamp.sh "$@"
  fi

  if [[ ${menu_choice} == *"RCLOCAL"* ]]; then

    enable_rclocal
  fi

  if [[ ${menu_choice} == *"SSH"* ]]; then

    enable_ssh
  fi

  if [[ ${menu_choice} == *"SYSTEMD"* ]]; then
    echo "SYSTEMD"
    enable_systemd
  fi
}

main "$@"
