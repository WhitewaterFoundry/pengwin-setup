#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

installdir='/usr/local'

function main()
{

echo "Uninstalling Cpp VisualStudio CLion integration"

sudo_rem_file "$installdir/bin/cmake"
sudo_rem_file "$installdir/bin/cpack"
sudo_rem_file "$installdir/bin/ctest"
sudo_rem_dir "$installdir/doc"
sudo_rem_file "$installdir/share/aclocal/cmake.m4"
sudo_rem_dir "$installdir/share/cmake-*"

}

if show_warning "" "" ; then
	main "$@"
fi
