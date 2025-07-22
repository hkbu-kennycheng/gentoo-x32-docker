FROM kennycheng/gentoo-stage3:x32

ARG MAKEOPTS
ARG EMERGE_DEFAULT_OPTS

RUN echo 'FEATURES="getbinpkg -ipc-sandbox -network-sandbox -pid-sandbox"' >> /etc/portage/make.conf \
    && echo 'USE="-busybox -gnome -gstreamer -gtk-doc -introspection -lua -lz4 -perl -python -ruby -tiff -vala -vulkan -zink X acpi alsa apparmor bluetooth cjk cpu_flags_x86_aes cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_mmx cpu_flags_x86_mmxext cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 cpu_flags_x86_sse4_1 cpu_flags_x86_sse4_2 cpu_flags_x86_ssse3 curl dbus dist-kernel elogind fcitx4 gles2 input_devices_libinput input_devices_synaptics jpeg lapack lm-sensors lzma opengl openh264 pulseaudio -system-mitkrb5 udev unicode v4l vaapi video_cards_amdgpu video_cards_i915 video_cards_intel video_cards_nouveau video_cards_radeon video_cards_radeonsi vim-syntax wayland webp xinerama"' >> /etc/portage/make.conf \
    && echo 'ACCEPT_LICENSE="@BINARY-REDISTRIBUTABLE"' >> /etc/portage/make.conf \
    && echo 'BINPKG_FORMAT="gpkg"' >> /etc/portage/make.conf \
    && getuto

RUN emerge-webrsync -q && emerge -qu dev-vcs/git

RUN cd /etc/portage && git init && git remote add origin https://github.com/hkbu-kennycheng/etc-portage-x32 && git fetch origin && git checkout -b main -t origin/main

RUN echo 'app-crypt/mit-krb5'  >> /etc/portage/package.mask/mit-krb5 \
    && echo 'app-mobilephone/scrcpy ~amd64'  >> /etc/portage/package.accept_keywords/scrcpy \
    && echo 'games-arcade/opensonic ~amd64'  >> /etc/portage/package.accept_keywords/opensonic \
    && echo 'net-fs/smbnetfs ~amd64'  >> /etc/portage/package.accept_keywords/smbnetfs \
    && echo 'gnome-base/librsvg **'  >> /etc/portage/package.accept_keywords/librsvg \
    && echo 'app-containers/waydroid ~amd64'  >> /etc/portage/package.accept_keywords/waydroid \
    && echo 'dev-python/gbinder ~amd64'  >> /etc/portage/package.accept_keywords/waydroid \
    && echo 'dev-python/pyclip ~amd64'  >> /etc/portage/package.accept_keywords/waydroid \
    && echo 'dev-libs/libglibutil ~amd64'  >> /etc/portage/package.accept_keywords/waydroid \
    && echo 'dev-libs/gbinder ~amd64'  >> /etc/portage/package.accept_keywords/waydroid \
    && echo 'app-i18n/fcitx:5 ~amd64' >> /etc/portage/package.accept_keywords/fcitx \
    && echo 'app-i18n/fcitx-configtool:5 ~amd64' >> /etc/portage/package.accept_keywords/fcitx \
    && echo 'app-i18n/fcitx-chinese-addons:5 ~amd64' >> /etc/portage/package.accept_keywords/fcitx \
    && echo 'app-i18n/fcitx-gtk:5 ~amd64' >> /etc/portage/package.accept_keywords/fcitx \
    && echo 'app-i18n/fcitx-qt:5 ~amd64' >> /etc/portage/package.accept_keywords/fcitx \
    && echo 'app-i18n/fcitx-table-extra:5 ~amd64' >> /etc/portage/package.accept_keywords/fcitx \
    && echo 'gui-wm/dwl ~amd64' >> /etc/portage/package.accept_keywords/dwl \
    && echo 'dev-lang/python -bluetooth' >> /etc/portage/package.use/python \
    && echo 'app-i18n/fcitx-qt qt5' >> /etc/portage/package.use/fcitx \
    && echo 'dev-libs/libxml2 python' >> /etc/portage/package.use/libxml2 \
    && echo 'media-libs/libsdl2 -fcitx4' >> /etc/portage/package.use/libsdl \
    && echo 'dev-qt/qtgui egl' >> /etc/portage/package.use/qtgui \
    && echo 'app-text/xmlto' >> /etc/portage/package.use/xmlto text \
    && echo 'dev-libs/boost -context' >> /etc/portage/package.use/boost \
    && echo 'app-containers/waydroid -apparmor'  >> /etc/portage/package.use/waydroid \
    && echo 'app-crypt/gcr gtk'  >> /etc/portage/package.use/gcr \
    && echo 'media-libs/harfbuzz icu'  >> /etc/portage/package.use/harfbuzz \
    && echo 'app-text/poppler cairo'  >> /etc/portage/package.use/poppler \
    && echo 'media-libs/gegl cairo'  >> /etc/portage/package.use/gegl \
    && echo 'media-libs/allegro vorbis png'  >> /etc/portage/package.use/allegro \
    && echo 'sys-libs/libcap static-libs'  >> /etc/portage/package.use/libcap \
    && echo 'virtual/imagemagick-tools tiff'  >> /etc/portage/package.use/imagemagick \
    && echo 'media-gfx/imagemagick tiff'  >> /etc/portage/package.use/imagemagick \
    && echo 'media-sound/mpg123 -pulseaudio'  >> /etc/portage/package.use/mpg123 \
    && echo 'dev-python/pillow -webp'  >> /etc/portage/package.use/pillow \
    && echo 'sys-kernel/installkernel dracut'  >> /etc/portage/package.use/installkernel

RUN mkdir -p /etc/portage/package.unmask \
    && echo '<gnome-base/librsvg-2.41' >> /etc/portage/package.unmask/librsvg

RUN emerge --exclude rust-bin -qDNu @world app-containers/docker app-containers/docker-cli app-admin/metalog app-containers/lxc app-editors/vim app-eselect/eselect-java app-eselect/eselect-repository app-i18n/fcitx:5 app-i18n/fcitx-configtool:5 app-i18n/fcitx-table-extra:5  app-i18n/fcitx-gtk:5 app-i18n/fcitx-qt:5 app-i18n/fcitx-chinese-addons:5 app-i18n/fcitx-table-extra:5 app-laptop/laptop-mode-tools app-misc/asciinema app-misc/jq app-misc/tmux app-mobilephone/scrcpy app-portage/gentoolkit app-text/mupdf dev-java/openjdk-bin dev-libs/weston dev-python/dbus-python dev-python/pip dev-util/android-tools dev-util/debootstrap dev-vcs/git games-arcade/opensonic media-fonts/noto media-gfx/feh media-gfx/gimp media-sound/alsa-utils media-sound/pamix media-video/mpv net-analyzer/speedtest-cli net-fs/smbnetfs net-fs/sshfs net-misc/aria2 net-misc/dhcpcd net-misc/tigervnc net-misc/yt-dlp net-wireless/iwd net-wireless/wpa_supplicant sys-apps/busybox sys-apps/flatpak sys-apps/pciutils sys-apps/usbutils sys-block/parted sys-firmware/sof-firmware sys-fs/bcache-tools sys-fs/btrfs-progs sys-kernel/linux-firmware sys-kernel/genkernel sys-process/htop sys-process/btop x11-apps/xev x11-apps/xhost x11-apps/xinput x11-apps/xrandr x11-apps/xsetroot x11-apps/xwd x11-base/xorg-server x11-misc/dmenu x11-misc/slock x11-misc/xautolock x11-misc/xclip x11-terms/st x11-wm/dwm gui-wm/dwl && rm -rf /var/cache/distfiles/*
