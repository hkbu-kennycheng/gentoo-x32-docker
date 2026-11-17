#!/bin/sh
# Build (and optionally push) one image from images/<name>/.
#
# Usage: scripts/build.sh <image-name> [--push]
# Env:   CONTAINER_ENGINE (default podman), MAKEOPTS, EMERGE_DEFAULT_OPTS,
#        GENTOO_MIRROR (passed to fetch-stage3.sh)
#
# Layer caching uses the engine's own image store: on a persistent self-hosted
# runner every run reuses the previous layers (do not pass --no-cache).
# Images with STAGE3_FLAVOR in image.env get the upstream stage3 tarball
# downloaded automatically.
#
# The build context is the repository root so stage4 images can COPY the
# shared images/stage4-common/ portage configuration; Containerfiles are
# referenced by -f.
set -eu

name=${1:?usage: $0 <image-name> [--push]}
push=${2:-}
root=$(cd "$(dirname "$0")/.." && pwd)
dir=$root/images/$name
engine=${CONTAINER_ENGINE:-podman}

[ -f "$dir/image.env" ] || { echo "error: no such image: $name" >&2; exit 1; }
. "$dir/image.env"
# shellcheck disable=SC2153 # set by image.env
tag=$IMAGE:$TAG

if [ -n "${STAGE3_FLAVOR:-}" ]; then
	"$root/scripts/fetch-stage3.sh" "$STAGE3_FLAVOR" "$dir"
fi

# --pull=newer keeps FROM bases current for scheduled builds.
"$engine" build --pull=newer -f "$dir/Containerfile" -t "$tag" \
	--build-arg "MAKEOPTS=${MAKEOPTS:--j$(nproc)}" \
	--build-arg "EMERGE_DEFAULT_OPTS=${EMERGE_DEFAULT_OPTS:---jobs=4}" \
	"$root"

if [ "$push" = "--push" ]; then
	"$engine" push "$tag"
	# shellcheck disable=SC2153 # set by image.env
	for alias in ${ALIASES:-}; do
		"$engine" tag "$tag" "$IMAGE:$alias"
		"$engine" push "$IMAGE:$alias"
	done
fi
