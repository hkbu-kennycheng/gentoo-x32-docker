#!/bin/sh

GENTOO_MIRROR="https://distfiles.gentoo.org"

wget -O tarball.tar.xz "${GENTOO_MIRROR}/releases/amd64/autobuilds/$(wget -O - ${GENTOO_MIRROR}/releases/amd64/autobuilds/latest-stage3-x32-openrc.txt | grep tar | awk '{print $1}')"
mkdir stage3
tar xvJf tarball.tar.xz -C stage3 --exclude ./dev* --exclude ./sys* --exclude ./proc* --exclude ./run* --exclude ./var/run*
