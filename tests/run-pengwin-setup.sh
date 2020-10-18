#!/usr/bin/env bash

last_param="${!#}"
dir_name="$(dirname "$0")"

export PATH="${dir_name}/stubs:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ ${last_param} == "--debug" ]]; then
  bash "${dir_name}/../pengwin-setup" "$@"
else
  bash "${dir_name}/../pengwin-setup" "$@" >/dev/null 2>&1
fi

unset last_param
unset dir_name
