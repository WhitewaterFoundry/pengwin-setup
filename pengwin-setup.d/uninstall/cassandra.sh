#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

sudoers_rgx='^[^#]*\bALL=.(root.) NOPASSWD: /bin/mount, /bin/umount'
profile_rgx='^[^#]*\bsudo mount -t proc proc /proc'

function main() {

  echo "Uninstalling Apache Cassandra"

  echo "Removing Cassandra-specific changes to /etc/sudoers"
  sudo_clean_file "/etc/sudoers" "$sudoers_rgx"

  echo "Removing Cassandra-specific changes to /etc/profile"
  sudo_clean_file "/etc/profile" "$profile_rgx"

  echo "Unlinking Cassandra from user directory"
  if [[ -d "$wHome/cassandra" ]]; then
    sudo unlink "/etc/cassandra"
  else
    echo "... not symlinked!"
  fi

  remove_package "cassandra"

  sudo_rem_dir "/etc/cassandra"
  sudo_rem_dir "/var/lib/cassandra"
  sudo_rem_dir "/var/log/cassandra"

  echo "Removing APT source..."
  sudo_rem_file "/etc/apt/sources.list.d/cassandra.list"

  echo "Removing APT key"
  sudo_rem_file "/etc/apt/trusted.gpg.d/cassandra.gpg"

}

if show_warning "Apache Cassandra" "$@"; then
  main "$@"
fi
