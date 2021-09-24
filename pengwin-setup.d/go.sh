#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "GO" --yesno "Would you like to download and install the latest Go from Google?" 8 70); then
  createtmp
  echo "Downloading Go using wget."
  wget "https://dl.google.com/go/go${GOVERSION}.linux-$(dpkg --print-architecture).tar.gz"
  echo "Unpacking tar binaries to /usr/local/go."
  sudo tar -C /usr/local -xzf go*.tar.gz
  echo "Creating ~/go/ for your projects."
  mkdir "${HOME}/go"

  echo "Creating ~/go/ default structure."
  mkdir "${HOME}/go/src"
  mkdir "${HOME}/go/bin"
  mkdir "${HOME}/go/pkg"

  echo "Setting Go environment variables GOROOT, GOPATH, and adding Go to PATH with export."

  echo "Saving Go environment variables to /etc/profile.d/go.sh so they will persist."
  sudo tee "/etc/profile.d/go.sh" <<EOF
#!/bin/sh

export GOROOT="/usr/local/go"
export GOPATH="\${HOME}/go"
export PATH="\${GOPATH}/bin:\${GOROOT}/bin:/usr/local/go/bin:\${PATH}"

EOF

  echo "Also for fish."
  sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"

  sudo tee "${__fish_sysconf_dir}/go.fish" <<EOF
#!/bin/fish

set --export GOROOT "/usr/local/go"
set --export GOPATH "\$HOME/go"
set --export PATH "\$GOPATH/bin:\$GOROOT/bin:/usr/local/go/bin:\$PATH"

EOF

  cleantmp
else
  echo "Skipping GO"
fi
