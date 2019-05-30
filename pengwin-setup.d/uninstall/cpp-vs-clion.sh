#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

installdir='/usr/local'
bin_cmake="$installdir/bin/cmake"
bin_cpack="$installdir/bin/cpack"
bin_ctest="$installdir/bin/ctest"
cmake_doc="$installdir/doc"
cmake_aclocal="$installdir/share/aclocal/cmake.m4"
cmake_share="$installdir/share/cmake-*"

function main()
{

echo "Uninstalling Cpp VisualStudio CLion integration"

sudo_rem_file "$bin_cmake"
sudo_rem_file "$bin_cpack"
sudo_rem_file "$bin_ctest"
sudo_rem_dir "$cmake_doc"
sudo_rem_file "$cmake_aclocal"
sudo_rem_dir "$cmake_share"

}

if show_warning "" "" ; then
	main "$@"
fi
