#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function install_terraform() {
  echo "Installing Terraform..."

  createtmp

  wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_$(dpkg --print-architecture).zip
  unzip terraform.zip
  sudo mv terraform /usr/bin
  sudo chmod +x /usr/bin/terraform

  echo "Installing bash-completion"
  sudo mkdir -p /etc/bash_completion.d
  sudo apt-get install -yq bash-completion

  terraform -install-autocomplete
  cleantmp
}

function install_and_set_cloud {
  EDITORCHOICE=$(
    whiptail --title "Cloud Management Menu" --checklist --separate-output "CLI tools for cloud management\n[SPACE to select, ENTER to confirm]:" 12 80 4 \
      "TERRAFORM" "Terraform                   " off 3>&1 1>&2 2>&3
  )
  
  local exit_status=$?
  
  if [[ ${exit_status} != 0 ]] ; then
    return
  fi
  
  # Ensure we're up to date
  updateupgrade
  
  if [[ ${EDITORCHOICE} == *"TERRAFORM"* ]] ; then
    
    install_terraform
    
  fi
  

}

install_and_set_cloud