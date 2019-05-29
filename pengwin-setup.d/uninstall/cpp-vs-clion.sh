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



}

if show_warning "" "" ; then
	main "$@"
fi
