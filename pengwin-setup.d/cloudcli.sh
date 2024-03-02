#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# Declare globals
declare SetupDir
declare GOVERSION
declare wHome

function install_terraform() {
  if (confirm --title "Terraform" --yesno "Would you like to install Terraform?" 8 40); then
    echo "Installing Terraform..."

    local terraform_version="1.2.9"

    sudo apt-get install -yq bash-completion unzip

    createtmp
    wget -O terraform.zip "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_$(dpkg --print-architecture).zip"
    unzip terraform.zip
    sudo mv terraform /usr/bin
    sudo chmod +x /usr/bin/terraform

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d


    terraform -install-autocomplete
    cleantmp
  else
    echo "Skipping Terraform"
  fi
}

function install_awscli() {

  if (confirm --title "AWS CLI" --yesno "Would you like to install the AWS CLI Using the Bundled Installer?\n\nPython is required" 10 90); then
    echo "Installing AWS CLI..."

    if ! (python3 --version); then
      bash "${SetupDir}"/pythonpi.sh "$@"

      if ! (python3 --version); then
        return
      fi
    fi

    createtmp
    sudo apt-get -y install unzip python3-distutils python3-venv
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

  if (confirm --title "Digital Ocean CTL" --yesno "Would you like to install the Digital Ocean CLI?" 8 70); then
    echo "Installing Digital Ocean CTL"

    createtmp

    echo "Checking for go"
    command_check '/usr/local/go/bin/go' 'version'
    local go_check=$?
    if [ $go_check -eq 1 ]; then
      echo "Downloading Go using wget."
      wget -c "https://dl.google.com/go/go${GOVERSION}.linux-$(dpkg --print-architecture).tar.gz"
      tar -xzf go*.tar.gz
      # shellcheck disable=SC2155
      export GOROOT=$(pwd)/go
      export PATH="${GOROOT}/bin:$PATH"
    else
      if [ $go_check -eq 2 ]; then
        # If go was only just installed previously without shell reset,
        # makes sure to set correct env variables
        export GOROOT=/usr/local/go
        export PATH="${GOROOT}/bin:$PATH"
      fi
    fi

    mkdir gohome
    # shellcheck disable=SC2155
    export GOPATH=$(pwd)/gohome

    echo "Checking for git"
    local git_exists

    if (git version); then
      git_exists=1
    else
      git_exists=0

      sudo apt-get -y -q install git
    fi

    echo "Building doctl"
    go get -u github.com/digitalocean/doctl/cmd/doctl
    sudo cp "${GOPATH}"/bin/doctl /usr/local/bin/doctl

    if [[ ${git_exists} -eq 0 ]]; then
      sudo apt-get -y -q purge git
      sudo apt-get -y -q autoremove
    fi

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion

    doctl completion bash | sudo tee /etc/bash_completion.d/doc.bash_completion >/dev/null
    doctl version

    cleantmp
  else
    echo "Skipping Digital Ocean CTL"

  fi
}

function install_kubectl() {

  echo "Installing Helm"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

  helm completion bash | sudo tee /etc/bash_completion.d/helm

  mkdir -p ~/.config/fish/completions
  helm completion fish >~/.config/fish/completions/helm.fish

  echo "Installing kubectl"
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get -y -q update
  sudo apt-get -y -q install kubectl

  kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
  kubectl completion fish >~/.config/fish/completions/kubectl.fish
}

function install_ibmcli() {

  if (confirm --title "IBM Cloud CLI" --yesno "Would you like to install the stand-alone IBM Cloud CLI?" 8 70); then
    echo "Installing IBM Cloud CLI..."

    createtmp

    curl -sL https://clis.ng.bluemix.net/download/bluemix-cli/latest/linux64 | tar -xvz

    cd Bluemix_CLI || return 1
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

    install_kubectl

    cleantmp
  else
    echo "Skipping IBM Cloud CLI"

  fi
}

function install_kubernetes() {

  if (confirm --title "Kubernetes tooling" --yesno "Would you like to install the Kubernetes tooling?" 10 90); then

    createtmp

    install_kubectl

    # Force the creation of a temporary .kube config directory
    kubectl config set-cluster fake --server=https://5.6.7.8 --insecure-skip-tls-verify
    kubectl config set-credentials nobody
    kubectl config set-context fake --cluster=fake --namespace=default --user=nobody

    # Install helm plugins: helm-github, helm-tiller, helm-restore

    helm init --client-only
    helm plugin install https://github.com/sagansystems/helm-github.git
    helm plugin install https://github.com/rimusz/helm-tiller
    helm plugin install https://github.com/maorfr/helm-restore

    # Get the kubectx script
    curl -O https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx
    chmod +x kubectx
    sudo mv kubectx /usr/local/bin/

    # Get the kubens script
    curl -O https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
    chmod +x kubens
    sudo mv kubens /usr/local/bin/

    # Add the completion script to the /etc/bash_completion.d directory.
    local base_url=https://raw.githubusercontent.com/ahmetb/kubectx/master/completion
    curl ${base_url}/kubectx.bash | sudo tee /etc/bash_completion.d/kubectx >/dev/null
    curl ${base_url}/kubens.bash | sudo tee /etc/bash_completion.d/kubens >/dev/null

    cleantmp

    if ! (confirm --title "KUBERNETES" --yesno "Would you like to link the tools to a local cluster in Docker or Rancher Desktop?" 9 75); then
      return
    fi

    if (! docker version 2>/dev/null); then
      bash "${SetupDir}/docker.sh" "$@"
    fi

    local kube_ctl="${wHome}/.kube/config"

    while [[ ! -f ${kube_ctl} ]]; do
      if ! (confirm --title "KUBERNETES" --yesno "Please enable Kubernetes in Docker or Rancher Desktop. Would you like to try again?" 9 75); then
        return
      fi
    done

    mkdir -p "${HOME}"/.kube
    ln -sf "${kube_ctl}" "${HOME}"/.kube/config

    kubectl cluster-info
    kubens kube-system
    kubectl get pods


  else
    echo "Skipping Kubernetes tooling"

  fi

}

function install_openstack() {

  if (confirm --title "OpenStack CLI" --yesno "Would you like to install the OpenStack command-line clients?\n\nPython is required" 10 90); then
    echo "Installing OpenStack CLI..."

    sudo apt-get -y -q install python3-dev python3-pip
    sudo pip3 install --upgrade setuptools
    sudo pip3 install --upgrade python-openstackclient

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion

    openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion >/dev/null

    openstack --version

  else
    echo "Skipping OpenStack CLI"

  fi

}

function main() {
  # shellcheck disable=SC2155
  local menu_choice=$(
    menu --title "Cloud Management Menu" --separate-output --checklist "CLI tools for cloud management\n[SPACE to select, ENTER to confirm]:" 16 60 7 \
      "AWS" "AWS CLI" off \
      "AZURE" "Azure CLI" off \
      "DO" "Digital Ocean CLI" off \
      "IBM" "IBM Cloud CLI" off \
      "KUBERNETES" "Kubernetes tooling (kubectl, helm)" off \
      "OPENSTACK" "OpenStack command-line clients      " off \
      "TERRAFORM" "Terraform                   " off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  echo "Selected:" "${menu_choice}"
  if [[ ! ${menu_choice} ]]; then
    return
  fi

  if [[ ${menu_choice} == *"AZURE"* ]]; then

    bash "${SetupDir}/azurecli.sh" "$@"

  fi

  if [[ ${menu_choice} == *"AWS"* ]]; then

    install_awscli "$@"

  fi

  if [[ ${menu_choice} == *"DO"* ]]; then

    install_doctl "$@"

  fi

  if [[ ${menu_choice} == *"IBM"* ]]; then

    install_ibmcli "$@"

  fi

  if [[ ${menu_choice} == *"KUBERNETES"* ]]; then

    install_kubernetes "$@"

  fi

  if [[ ${menu_choice} == *"OPENSTACK"* ]]; then

    install_openstack "$@"

  fi

  if [[ ${menu_choice} == *"TERRAFORM"* ]]; then

    install_terraform "$@"

  fi
}

main "$@"
