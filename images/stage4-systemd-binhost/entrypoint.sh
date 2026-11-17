#!/bin/sh

quickpkg --include-unmodified-config y 'sys-*/*' 'dev-*/*' 'net-*/*' 'x11-*/*' 'media-*/*' 'app-*/*'
cd /var/cache/binpkgs && python -m http.server
