#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main()
{

echo "Uninstall ibus non-latin input modifications"

echo "Removing fcitx environment variable modifications..."
sudo_rem_file "/etc/profile.d/ibus.sh"

echo "Removing ibus packages..."
remove_package "ibus" "^ibus-gtk*" ibus-sunpinyin ibus-libpinyin ibus-rime ibus-pinyin ibus-chewing ibus-mozc mozc-utils-gui ibus-kkc ibus-hangul ibus-unikey ibus-table "^ibus-table-*"

echo "Regenerating start-menu entry cache..."
bash ${SetupDir}/shortcut.sh --yes

}

if show_warning "ibus improved non-latin input" "$@" ; then
	main "$@"
fi
