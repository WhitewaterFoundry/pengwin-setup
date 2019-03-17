#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function enable_rclocal() {

  if (confirm --title "rc.local" --yesno "Would you like to enable rc.local support for running scripts at Pengwin launch?" 10 60) ; then
    echo "Enabling rc.local..."

    echo '%sudo   ALL=NOPASSWD: /bin/bash /etc/rc.local' | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/rclocal
    echo 'sudo /bin/bash /etc/rc.local' | sudo tee /etc/profile.d/rclocal.sh

    sudo mkdir -p /etc/boot.d

  else
    echo "Skipping rc.local"

    return 1
  fi

}

function enable_ssh() {

  if (confirm --title "SSH Server" --yesno "Would you like to enable SSH Server?" 10 60) ; then

    enable_rclocal

    if [[ $? != 0 ]]; then
      echo "Cancelled"
      return 1
    fi

    echo "Enabling SSH Server..."

    local port=$(whiptail --title "Enter the desired SSH Port" --inputbox "SSH Port: " 8 50 "2222" 3>&1 1>&2 2>&3)
    if [[ -z ${port} ]] ; then
      echo "Cancelled"
      return 1
    fi

    local address=$(whiptail --title "Enter the desired Listen Address" --inputbox "Listen Address: " 8 50 "127.0.0.1" 3>&1 1>&2 2>&3)
    if [[ -z ${address} ]]; then
      echo "Cancelled"
      return 1
    fi

    local sshd_file=/etc/ssh/sshd_config

    sudo cp ${sshd_file} ${sshd_file}.`date '+%Y-%m-%d_%H-%M-%S'`.back

    sudo sed -i '/^# configured by Pengwin/ d' ${sshd_file}
    sudo sed -i '/^ListenAddress/ d' ${sshd_file}
    sudo sed -i '/^Port/ d' ${sshd_file}
    sudo sed -i '/^PasswordAuthentication/ d' ${sshd_file}
    echo "# configured by Pengwin"      | sudo tee -a ${sshd_file}
    echo "ListenAddress ${address}"	| sudo tee -a ${sshd_file}
    echo "Port ${port}"          | sudo tee -a ${sshd_file}
    echo "PasswordAuthentication yes" | sudo tee -a ${sshd_file}

    sudo service ssh --full-restart

    sshd_status=$(service ssh status)
    if [[ $sshd_status = *"is not running"* ]]; then
      sudo service ssh --full-restart
    fi

    sudo tee /etc/boot.d/ssh << EOF
#!/bin/bash

sshd_status=\$(service ssh status)
if [[ \${sshd_status} = *"is not running"* ]]; then
  service ssh --full-restart
fi

EOF

    sudo chmod 700 /etc/boot.d/ssh

  else
    echo "Skipping SSH Server"
  fi

}

function main() {

  MENU_CHOICE=""

  menu --title "Services Menu" --checklist --separate-output "Enables service support\n[SPACE to select, ENTER to confirm]:" 10 70 2 \
    "RCLOCAL" "Enable running scripts at startup from rc.local " off \
    "SSH" "Enable SSH server" off

  if [[ ${MENU_CHOICE} == *"RCLOCAL"* ]] ; then

      enable_rclocal "$@"
  fi

  if [[ ${MENU_CHOICE} == *"SSH"* ]] ; then

      enable_ssh "$@"
  fi
}

main "$@"