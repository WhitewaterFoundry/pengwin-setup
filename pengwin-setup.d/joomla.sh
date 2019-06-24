#!/usr/bin/env bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir
JOOMLA_VERSION="3-9-8"

function main() {

  createtmp

  bash ${SetupDir}/lamp.sh "$@" --yes

  wget -O Joomla.tar.bz2 https://downloads.joomla.org/cms/joomla3/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Stable-Full_Package.tar.bz2?format=bz2
  sudo tar -xjvf Joomla.tar.bz2 --overwrite --directory /var/www/html/ #--strip-components 1 docker/docker

  sudo rm -f /var/www/html/index.html

  wslview "http://localhost/index.php"

  cleantmp
}

main "$@"