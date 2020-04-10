#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main()
{

echo "Uninstalling LaTeX"

remove_package texlive-full texlive-latex-extra texlive-latex-recommended texlive-latex-base

}

if show_warning "LaTeX" "$@" ; then
	main "$@"
fi
