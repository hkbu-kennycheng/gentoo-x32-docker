#!/bin/sh
# emerge @world plus the stage4 package set, retrying once with `emerge
# --resume` so a single transient failure does not discard a multi-hour build.
#
# Usage: emerge-world.sh [emerge options...]
# Env:   STAGE4_SET (default /etc/portage/sets/stage4)
#
# Exit status: 0 on success, otherwise the failure of the first pass (a
# retry that has "nothing to resume" means the failure was not a build
# failure, so it is reported as-is instead of being swallowed).
set -u

set_file=${STAGE4_SET:-/etc/portage/sets/stage4}
# emerge has no comment syntax: strip comments and blank lines.
pkgs=$(sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$set_file")

status=0
# shellcheck disable=SC2086 # the package list must be word-split
emerge -qDNu @world "$@" ${pkgs} || status=$?

if [ "${status}" -ne 0 ]; then
	if emerge --resume --pretend 2>&1 | grep -qi 'nothing to resume'; then
		echo "::error::emerge failed and there is nothing to resume" >&2
		exit "${status}"
	fi
	echo "::warning::emerge failed (status ${status}); retrying with --resume" >&2
	emerge -q --resume || exit $?
fi

rm -rf /var/cache/distfiles/*
