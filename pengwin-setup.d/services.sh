#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir

function enable_rclocal() {

  if (confirm --title "rc.local" --yesno "Would you like to enable rc.local support for running scripts at Pengwin launch?" 10 60) ; then
    echo "Enabling rc.local..."

    local cmd="/bin/bash /etc/rc.local"
    echo "%sudo   ALL=NOPASSWD: ${cmd}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/rclocal

    local profile_rclocal="/etc/profile.d/rclocal.sh"
    sudo tee "${profile_rclocal}" << EOF
#!/bin/bash

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then

  sudo ${cmd}
fi

EOF
    sudo mkdir -p /etc/boot.d

  else
    echo "Skipping rc.local"

    return 1
  fi

}

function enable_ssh() {

  if (confirm --title "SSH Server" --yesno "Would you like to enable SSH Server?" 10 60) ; then

    echo "Enabling SSH Server..."

    local port

    if [[ -z "${NON_INTERACTIVE}" ]]; then
      port=$(whiptail --title "Enter the desired SSH Port" --inputbox "SSH Port: " 8 50 "2222" 3>&1 1>&2 2>&3)
      if [[ -z ${port} ]] ; then
        echo "Cancelled"
        return 1
      fi
    else
      port="2222"
    fi

    local address

    if [[ -z "${NON_INTERACTIVE}" ]]; then
      address=$(whiptail --title "Enter the desired Listen Address" --inputbox "Listen Address: " 8 50 "127.0.0.1" 3>&1 1>&2 2>&3)
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
    echo "# configured by Pengwin"      | sudo tee -a ${sshd_file}
    echo "ListenAddress ${address}"	| sudo tee -a ${sshd_file}
    echo "Port ${port}"          | sudo tee -a ${sshd_file}
    echo "UsePrivilegeSeparation no"  | sudo tee -a ${sshd_file}
    echo "PasswordAuthentication yes" | sudo tee -a ${sshd_file}

    sudo service ssh --full-restart

    sshd_status=$(service ssh status)
    if [[ $sshd_status = *"is not running"* ]]; then
      sudo service ssh --full-restart > /dev/null 2>&1
    fi

    local startSsh="/usr/bin/start-ssh"
    sudo tee "${startSsh}" << EOF
#!/bin/bash

sshd_status=\$(service ssh status)
if [[ \${sshd_status} = *"is not running"* ]]; then
  service ssh --full-restart > /dev/null 2>&1
fi

EOF

    sudo chmod 700 "${startSsh}"

    echo "%sudo   ALL=NOPASSWD: ${startSsh}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/start-ssh

    local profile_startssh="/etc/profile.d/start-ssh.sh"
    sudo tee "${profile_startssh}" << EOF
#!/bin/bash

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then

  sudo ${startSsh}
fi

EOF

  else
    echo "Skipping SSH Server"
  fi

}

function main() {

  if [[ "$1" == "--enable-ssh" ]] ; then
    enable_ssh

    return
  fi

  local menu_choice=$(

    menu --title "Services Menu" --checklist --separate-output "Enables various services\n[SPACE to select, ENTER to confirm]:" 12 70 5 \
      "CASSANDRA" "Install the NoSQL server Cassandra from Apache " off \
      "KEYCHAIN" "Install Keychain, the OpenSSH key manager" off \
      "LAMP" "Install LAMP Stack" off \
      "RCLOCAL" "Enable running scripts at startup from rc.local " off \
      "SSH" "Enable SSH server" off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"CASSANDRA"* ]] ; then
    echo "CASSANDRA"
    bash ${SetupDir}/cassandra.sh "$@"
  fi

  if [[ ${menu_choice} == *"KEYCHAIN"* ]] ; then
    echo "KEYCHAIN"
    bash ${SetupDir}/keychain.sh "@"
  fi

  if [[ ${menu_choice} == *"LAMP"* ]] ; then
    echo "LAMP"
    bash ${SetupDir}/lamp.sh "@"
  fi

  if [[ ${menu_choice} == *"RCLOCAL"* ]] ; then

    enable_rclocal
  fi

  if [[ ${menu_choice} == *"SSH"* ]] ; then

    enable_ssh
  fi
}

main "$@"
