#!/bin/sh
# Download the latest upstream x32 stage3 tarball for a Containerfile FROM scratch.
#
# Usage: scripts/fetch-stage3.sh <openrc|systemd> <image-dir>
# Env:   GENTOO_MIRROR (default https://distfiles.gentoo.org)
#
# Writes <image-dir>/stage3.tar.xz (verified against the mirror .sha256 when
# published), which is what images/stage3-*/Containerfile adds.
set -eu

flavor=${1:?usage: $0 <openrc|systemd> <image-dir>}
dest=${2:?usage: $0 <openrc|systemd> <image-dir>}
mirror=${GENTOO_MIRROR:-https://distfiles.gentoo.org}
base=$mirror/releases/amd64/autobuilds

rel=$(curl -fsSL "$base/latest-stage3-x32-$flavor.txt" |
	grep -v '^#' | grep '\.tar\.xz ' | awk '{print $1}')
[ -n "$rel" ] || { echo "error: no stage3 published for flavor $flavor" >&2; exit 1; }
echo "stage3 ($flavor): $rel"

mkdir -p "$dest"
curl -fsSL --retry 3 -o "$dest/stage3.tar.xz.part" "$base/$rel"
# The .sha256 file is PGP-clearsigned; the hash is its first plain hex line.
if sum=$(curl -fsSL "$base/$rel.sha256"); then
	expected=$(echo "$sum" | grep -E '^[0-9a-f]{64}' | awk '{print $1}')
	printf '%s  %s\n' "$expected" "$dest/stage3.tar.xz.part" | sha256sum -c - >/dev/null
	echo "sha256 ok: $expected"
fi
mv "$dest/stage3.tar.xz.part" "$dest/stage3.tar.xz"
