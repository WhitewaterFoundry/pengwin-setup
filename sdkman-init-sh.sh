#!/usr/bin/env sh

#
#   Copyright 2017 Marco Vermeulen
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# set env vars if not set
if [ -z "$SDKMAN_VERSION" ]; then
	export SDKMAN_VERSION="@SDKMAN_VERSION@"
fi

if [ -z "$SDKMAN_CANDIDATES_API" ]; then
	export SDKMAN_CANDIDATES_API="@SDKMAN_CANDIDATES_API@"
fi

if [ -z "$SDKMAN_DIR" ]; then
	export SDKMAN_DIR="$HOME/.sdkman"
fi

# Load the sdkman config if it exists.
if [ -f "${SDKMAN_DIR}/etc/config" ]; then
	# shellcheck disable=SC1090
	. "${SDKMAN_DIR}/etc/config"
fi

# infer platform
infer_platform() {
	kernel="$(uname -s)"
	machine="$(uname -m)"

	case $kernel in
	Linux)
		case $machine in
		i686)
			echo "LinuxX32"
			;;
		x86_64)
			echo "LinuxX64"
			;;
		armv7l)
			echo "LinuxARM32"
			;;
		armv8l)
			echo "LinuxARM64"
			;;
		aarch64)
			echo "LinuxARM64"
			;;
		*)
			echo "LinuxX64"
			;;
		esac
		;;
	Darwin)
		case $machine in
		x86_64)
			echo "DarwinX64"
			;;
		arm64)
			# shellcheck disable=SC2154
			if [ "$sdkman_rosetta2_compatible" = 'true' ]; then
				echo "DarwinX64"
			else
				echo "DarwinARM64"
			fi
			;;
		*)
			echo "DarwinX64"
			;;
		esac
		;;
	*)
		echo "$kernel"
		;;
	esac
}

__sdkman_export_candidate_home() {
	candidate_name="$1"
	candidate_dir="$2"
	candidate_home_var="$(echo ${candidate_name} | tr '[:lower:]' '[:upper:]')_HOME"
	export "$(echo "$candidate_home_var")"="$candidate_dir"
	
}

__sdkman_prepend_candidate_to_path() {
	candidate_dir="$1"
	candidate_bin_dir=$(__sdkman_determine_candidate_bin_dir "$candidate_dir")
	echo "$PATH" | grep -q "$candidate_dir" || PATH="${candidate_bin_dir}:${PATH}"
	
	unset CANDIDATE_BIN_DIR
}

__sdkman_determine_candidate_bin_dir() {
	candidate_dir="$1"
	if [ -d "${candidate_dir}/bin" ]; then
		echo "${candidate_dir}/bin"
	else
		echo "$candidate_dir"
	fi
	
	unset candidate_dir
}

SDKMAN_PLATFORM="$(infer_platform)"
export SDKMAN_PLATFORM

# Create upgrade delay file if it doesn't exist
if [ ! -f "${SDKMAN_DIR}/var/delay_upgrade" ]; then
	touch "${SDKMAN_DIR}/var/delay_upgrade"
fi

# set curl connect-timeout and max-time
if [ -z "$sdkman_curl_connect_timeout" ]; then sdkman_curl_connect_timeout=7; fi
if [ -z "$sdkman_curl_max_time" ]; then sdkman_curl_max_time=10; fi

# set curl retry
if [ -z "${sdkman_curl_retry}" ]; then sdkman_curl_retry=0; fi

# set curl retry max time in seconds
if [ -z "${sdkman_curl_retry_max_time}" ]; then sdkman_curl_retry_max_time=60; fi

# set curl to continue downloading automatically
if [ -z "${sdkman_curl_continue}" ]; then sdkman_curl_continue=true; fi

# Read list of candidates and set array
SDKMAN_CANDIDATES_CACHE="${SDKMAN_DIR}/var/candidates"
SDKMAN_CANDIDATES_CSV=$(cat "$SDKMAN_CANDIDATES_CACHE")
SDKMAN_CANDIDATES=$(printf '%s' "${SDKMAN_CANDIDATES_CSV}" | tr ',' ' ')

export SDKMAN_CANDIDATES_DIR="${SDKMAN_DIR}/candidates"

for candidate_name in ${SDKMAN_CANDIDATES}; do
	candidate_dir="${SDKMAN_CANDIDATES_DIR}/${candidate_name}/current"
	if [ -h "$candidate_dir" ] || [ -d "${candidate_dir}" ]; then
		__sdkman_export_candidate_home "$candidate_name" "$candidate_dir"
		__sdkman_prepend_candidate_to_path "$candidate_dir"
	fi
done
unset candidate_name candidate_dir
export PATH

