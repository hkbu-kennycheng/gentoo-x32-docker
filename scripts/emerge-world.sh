#!/bin/bash
# emerge @world plus the stage4 package set, dropping any set member whose
# dependency tree cannot be satisfied (masked/unresolvable) and reporting it,
# so the broken atom can be fixed upstream instead of failing the whole build.
#
# Usage: emerge-world.sh [emerge options...]
# Env:   STAGE4_SET (default /etc/portage/sets/stage4)
set -uo pipefail

set_file=${STAGE4_SET:-/etc/portage/sets/stage4}
# emerge has no comment syntax: strip comments and blank lines.
mapfile -t pkgs < <(sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$set_file")
removed=()

for _ in $(seq 1 100); do
	if out=$(emerge --pretend "$@" @world "${pkgs[@]}" 2>&1) && grep -q '^Total: ' <<<"$out"; then
		break
	fi
	# Walk the "required by" chain and drop the first *set member* on it.
	culprit=
	while read -r atom; do
		if printf '%s\n' "${pkgs[@]}" | grep -qxF "${atom}"; then
			culprit=${atom}
			break
		fi
	done < <(grep -oE '\(dependency required by "[^" ]+' <<<"$out" |
		sed -E 's/.*"//')

	if [[ -z ${culprit} ]]; then
		echo "FAILED: unresolvable dependency tree" >&2
		printf '%s\n' "${out}" | tail -n 30 >&2
		exit 1
	fi
	echo "::warning::dropping ${culprit}: dependency tree does not resolve for x32"
	removed+=("${culprit}")
	mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | grep -vxF "${culprit}")
done

if ((${#removed[@]})); then
	echo "::warning::dropped from the stage4 set: ${removed[*]}" >&2
fi

emerge --quiet --jobs 4 "$@" @world "${pkgs[@]}"
