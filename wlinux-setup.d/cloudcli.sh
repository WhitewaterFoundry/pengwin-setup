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

function install_awscli() {

  if (whiptail --title "AWS CLI" --yesno "Would you like to install the AWS CLI Using the Bundled Installer?\n\nPython is required" 10 90) ; then
    echo "Installing AWS CLI..."

    if ! (python3 --version); then
      bash ${SetupDir}/pythonpi.sh "$@"

      if ! (python3 --version); then
        return
      fi
    fi

    createtmp

    wget -O awscli-bundle.zip https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    unzip awscli-bundle.zip

    sudo python3 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion

    sudo cp /usr/local/aws/bin/aws_completer /usr/local/bin
    sudo cp /usr/local/aws/bin/aws_bash_completer /etc/bash_completion.d/

    aws --version

    cleantmp
  else
    echo "Skipping AWS CLI"

  fi
}

function install_and_set_cloud {
  EDITORCHOICE=$(
    whiptail --title "Cloud Management Menu" --checklist --separate-output "CLI tools for cloud management\n[SPACE to select, ENTER to confirm]:" 12 80 4 \
      "TERRAFORM" "Terraform                   " off \
      "AWS" "AWS CLI" off 3>&1 1>&2 2>&3
  )

  echo "Selected:" ${EDITORCHOICE}
  if [[ ! ${EDITORCHOICE} ]] ; then
    return
  fi
  
  # Ensure we're up to date
  updateupgrade
  
  if [[ ${EDITORCHOICE} == *"TERRAFORM"* ]] ; then
    
    install_terraform
    
  fi
  

  if [[ ${EDITORCHOICE} == *"AWS"* ]] ; then

    install_awscli

  fi

}

install_and_set_cloud