#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function install_terraform() {
  if (confirm --title "Terraform" --yesno "Would you like to install Terraform?" 8 40) ; then
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
  else
    echo "Skipping Terraform"
  fi
}

function install_awscli() {

  if (confirm --title "AWS CLI" --yesno "Would you like to install the AWS CLI Using the Bundled Installer?\n\nPython is required" 10 90) ; then
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

function install_openstack() {

  if (confirm --title "OpenStack CLI" --yesno "Would you like to install the OpenStack command-line clients?\n\nPython 2.7+ is required" 10 90) ; then
    echo "Installing OpenStack CLI..."

    sudo apt-get -y -q install python-dev python-pip
    sudo pip install --upgrade setuptools
    sudo pip install --upgrade python-openstackclient

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion

    openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null

    openstack --version

  else
    echo "Skipping OpenStack CLI"

  fi

}

function main() {
  local choice=$(
    whiptail --title "Cloud Management Menu" --checklist --separate-output "CLI tools for cloud management\n[SPACE to select, ENTER to confirm]:" 12 60 4 \
      "TERRAFORM" "Terraform                   " off \
      "AWS" "AWS CLI" off \
      "OPENSTACK" "OpenStack command-line clients      " off 3>&1 1>&2 2>&3
  )

  echo "Selected:" ${choice}
  if [[ ! ${choice} ]] ; then
    return
  fi
  
  if [[ ${choice} == *"TERRAFORM"* ]] ; then
    
    install_terraform
    
  fi
  

  if [[ ${choice} == *"AWS"* ]] ; then

    install_awscli

  fi

  if [[ ${choice} == *"OPENSTACK"* ]] ; then

    install_openstack

  fi

}

main "$@"
