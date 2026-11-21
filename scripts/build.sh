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

# Keep portage's job count within this build's own CPU budget. scripts/build.sh
# already passes MAKEOPTS, but a build on a machine where the build arg does not
# reach make.conf (e.g. a different runner) can fall back to a very large
# nproc-derived job count and OOM. Clamp both settings here so the job count is
# deterministic and bounded no matter which runner picks the job up.
MAKEOPTS=${MAKEOPTS:--j$(nproc)}
EMERGE_DEFAULT_OPTS=${EMERGE_DEFAULT_OPTS:---jobs=2}
case ${MAKEOPTS} in
	-j[0-9]*) MAKEOPTS=-j$(( ${MAKEOPTS#-j} < $(nproc) ? ${MAKEOPTS#-j} : $(nproc) )) ;;
esac
export MAKEOPTS EMERGE_DEFAULT_OPTS

# Images that clone the x32-overlay inside the build (image.env: X32_OVERLAY=1)
# get the overlay's current commit as a build arg. The Containerfile echoes it
# in the sync step, so a new overlay commit changes the step's text and the
# layer from an older checkout is not reused.
extra_args=
if [ "${X32_OVERLAY:-0}" = 1 ]; then
	overlay_commit=$(git ls-remote https://github.com/hkbu-kennycheng/x32-overlay.git refs/heads/main | cut -f1)
	[ -n "$overlay_commit" ] || { echo "error: could not resolve x32-overlay HEAD" >&2; exit 1; }
	extra_args="--build-arg X32_OVERLAY_COMMIT=$overlay_commit"
fi

# Rootless podman needs a runtime dir that survives the whole build. On the
# openrc+elogind CI host /run/user/<uid> disappears when the runner session is
# reaped, which aborts in-flight builds ("lstat /run/user/1000: no such file or
# directory"), so default to a tmpfs path instead (the action also pins one
# via XDG_RUNTIME_DIR).
if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "${XDG_RUNTIME_DIR}" ]; then
	XDG_RUNTIME_DIR=${CI_XDG_RUNTIME_DIR:-/dev/shm/ci-runtime-$(id -u)}
	install -d -m 0700 "$XDG_RUNTIME_DIR"
	export XDG_RUNTIME_DIR
fi

# --pull=newer keeps FROM bases current for scheduled builds.
# shellcheck disable=SC2086 # extra_args must be word-split
"$engine" build --pull=newer -f "$dir/Containerfile" -t "$tag" \
	--build-arg "MAKEOPTS=${MAKEOPTS}" \
	--build-arg "EMERGE_DEFAULT_OPTS=${EMERGE_DEFAULT_OPTS}" \
	${extra_args} \
	"$root"

if [ "$push" = "--push" ]; then
	"$engine" push "$tag"
	# shellcheck disable=SC2153 # set by image.env
	for alias in ${ALIASES:-}; do
		"$engine" tag "$tag" "$IMAGE:$alias"
		"$engine" push "$IMAGE:$alias"
	done
fi
