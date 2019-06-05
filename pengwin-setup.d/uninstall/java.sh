#!/bin/bash

source $(dirname "$0")/uninstall-common.sh
sdkman_rgx1='^#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!'
sdkman_rgx2='^[^#]*\bexport SDKMAN_DIR="$SDKMAN_DIR"'
sdkman_rgx3='^[^#]*\b[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"'

function main()
{

echo "Uninstalling SDKMAN (Java)"

rem_dir "$HOME/.sdkman"

clean_file "$HOME/.bashrc"
clean_file "$HOME/.zshrc"
clean_file "$HOME/.profile"
clean_file "$HOME/.bash_profile"

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/sdkman.bash"

}

if show_warning "SDKMAN (Java)" "$@" ; then
	main "$@"
fi
