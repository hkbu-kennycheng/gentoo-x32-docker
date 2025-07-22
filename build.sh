#!/bin/sh

DOCKER_TAG="kennycheng/gentoo-stage3:x32-systemd"
GENTOO_MIRROR="https://distfiles.gentoo.org"

wget -O tarball.tar.xz "${GENTOO_MIRROR}/releases/amd64/autobuilds/$(wget -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/latest-stage3-x32-systemd.txt | grep tar | awk '{print $1}')"
mkdir stage3
tar xvJf tarball.tar.xz -C stage3
docker build -t ${DOCKER_TAG} .
rm -rf tarball.tar.xz stage3
