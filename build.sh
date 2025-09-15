#!/bin/sh

podman build -t  docker.io/kennycheng/gentoo-stage4:x32-systemd --no-cache --build-arg MAKEOPTS=-j32 --build-arg EMERGE_DEFAULT_OPTS=--jobs=4 .
