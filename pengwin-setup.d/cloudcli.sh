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

    local terraform_version="1.12.1"

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

  if (confirm --title "AWS CLI" --yesno "Would you like to install the AWS CLI version 2?" 8 70); then
    echo "Checking for existing AWS CLI installation..."

    # Check if AWS CLI v1 is installed
    if [[ -d "/usr/local/aws" ]] && [[ -f "/usr/local/bin/aws" ]]; then
      local aws_version
      aws_version=$(/usr/local/bin/aws --version 2>&1)
      
      if [[ "${aws_version}" == *"aws-cli/1."* ]]; then
        echo "AWS CLI version 1 is currently installed."
        
        if (confirm --title "AWS CLI v1 Detected" --yesno "AWS CLI version 1 is installed. To install version 2, version 1 must be uninstalled first.\n\nWould you like to uninstall AWS CLI version 1?" 10 75); then
          echo "Uninstalling AWS CLI version 1..."
          bash "${SetupDir}/uninstall/awscli.sh" --skip-warning "$@"
        else
          echo "Installation cancelled. AWS CLI version 1 will not be removed."
          return 1
        fi
      fi
    fi

    echo "Installing AWS CLI version 2..."

    createtmp
    sudo apt-get -y -q install unzip curl

    # Download and install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install

    echo "Installing bash-completion"
    sudo mkdir -p /etc/bash_completion.d
    sudo apt-get install -yq bash-completion

    # AWS CLI v2 has built-in completion support
    /usr/local/bin/aws --version
    echo "complete -C '/usr/local/bin/aws_completer' aws" | sudo tee /etc/bash_completion.d/aws >/dev/null

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

    doctl completion bash | sudo tee /etc/bash_completion.d/doctl.bash_completion >/dev/null
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
  install_packages apt-transport-https ca-certificates curl gnupg

  sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

  # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly

  update_packages
  install_packages kubectl

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

    local kube_ctl="${wHome}/.kube/config"

    if [[ ! ${SKIP_CONFIMATIONS} ]]; then
      while [[ ! -f ${kube_ctl} ]]; do
        if ! (confirm --title "KUBERNETES" --yesno "Please enable Kubernetes in Docker or Rancher Desktop. Would you like to try again?" 9 75); then
          return
        fi
      done
    fi

    mkdir -p "${HOME}"/.kube
    ln -sf "${kube_ctl}" "${HOME}"/.kube/config

    kubectl cluster-info
    kubens kube-system
    kubectl get pods

  else
    echo "Skipping Kubernetes tooling"
    return 1
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
  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(
    menu --title "Cloud Management Menu" "${DIALOG_TYPE}" "CLI tools for cloud management\n[ENTER to confirm]:" 16 62 7 \
      "AWS" "AWS CLI" ${OFF} \
      "AZURE" "Azure CLI" ${OFF} \
      "DO" "Digital Ocean CLI" ${OFF} \
      "IBM" "IBM Cloud CLI" ${OFF} \
      "KUBERNETES" "Kubernetes tooling (kubectl, helm)" ${OFF} \
      "OPENSTACK" "OpenStack command-line clients      " ${OFF} \
      "TERRAFORM" "Terraform                   " ${OFF}

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  echo "Selected:" "${menu_choice}"
  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  local exit_status

  if [[ ${menu_choice} == *"AZURE"* ]]; then
    bash "${SetupDir}/azurecli.sh" "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"AWS"* ]]; then
    install_awscli "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"DO"* ]]; then
    install_doctl "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"IBM"* ]]; then
    install_ibmcli "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"KUBERNETES"* ]]; then
    install_kubernetes "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"OPENSTACK"* ]]; then
    install_openstack "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"TERRAFORM"* ]]; then
    install_terraform "$@"
    exit_status=$?
  fi

  if [[ ${exit_status} != 0 && ! ${NON_INTERACTIVE} ]]; then
    local status
    main "$@"
    status=$?
    return $status
  fi

}

main "$@"
