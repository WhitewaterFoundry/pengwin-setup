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

function install_doctl() {

  if (confirm --title "Digital Ocean CTL" --yesno "Would you like to install the Digital Ocean Commandline Tool?" 8 70) ; then
    echo "Installing Digital Ocean CTL"

    createtmp

    curl -L https://github.com/digitalocean/doctl/releases/download/v1.15.0/doctl-1.15.0-linux-amd64.tar.gz | tar -xzv
    sudo cp doctl /usr/local/bin
    doctl version

    cleantmp
  else
    echo "Skipping Digital Ocean CTL"

  fi
}
function install_ibmcli() {

  if (confirm --title "IBM Cloud CLI" --yesno "Would you like to install the stand-alone IBM Cloud CLI?" 8 70) ; then
    echo "Installing IBM Cloud CLI..."

    createtmp

    curl -sL https://clis.ng.bluemix.net/download/bluemix-cli/latest/linux64 | tar -xvz

    cd Bluemix_CLI
    sudo ./install

    yes | ibmcloud plugin install dev -r 'IBM Cloud'
    yes | ibmcloud plugin install cloud-functions -r 'IBM Cloud'
    yes | ibmcloud plugin install container-registry -r 'IBM Cloud'
    yes | ibmcloud plugin install container-service -r 'IBM Cloud'
    yes | ibmcloud plugin install sdk-gen -r 'IBM Cloud'

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion

    sudo cp /usr/local/ibmcloud/autocomplete/bash_autocomplete /etc/bash_completion.d/ibmcli_completion

    ibmcloud --version

    echo "Installing Helm"
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

    wget https://raw.githubusercontent.com/helm/helm/master/scripts/completions.bash
    sudo cp completions.bash /etc/bash_completion.d/helm_completions.bash

    echo "Installing kubectl"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get -y -q update
    sudo apt-get -y -q install kubectl

    cleantmp
  else
    echo "Skipping IBM Cloud CLI"

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
    whiptail --title "Cloud Management Menu" --checklist --separate-output "CLI tools for cloud management\n[SPACE to select, ENTER to confirm]:" 14 60 5 \
      "AWS" "AWS CLI" off \
      "AZURE" "Azure CLI" off \
      "DO" "Digital Ocean Commandline tool" off \
      "IBM" "IBM Cloud CLI" off \
      "OPENSTACK" "OpenStack command-line clients      " off \
      "TERRAFORM" "Terraform                   " off 3>&1 1>&2 2>&3
  )

  echo "Selected:" ${choice}
  if [[ ! ${choice} ]] ; then
    return
  fi
  
  if [[ ${choice} == *"AZURE"* ]] ; then

    bash "${SetupDir}/azurecli.sh" "$@"

  fi

  if [[ ${choice} == *"AWS"* ]] ; then

    install_awscli "$@"

  fi

  if [[ ${choice} == *"DO"* ]] ; then

    install_doctl "$@"

  fi

  if [[ ${choice} == *"IBM"* ]] ; then

    install_ibmcli "$@"

  fi

  if [[ ${choice} == *"OPENSTACK"* ]] ; then

    install_openstack "$@"

  fi

  if [[ ${choice} == *"TERRAFORM"* ]] ; then

    install_terraform "$@"

  fi
}

main "$@"

