FROM kennycheng/gentoo-stage3:x32

ARG MAKEOPTS

RUN echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' | cat >> /etc/portage/make.conf
RUN echo 'USE="-busybox -gnome -gstreamer -gtk-doc -introspection -lua -lz4 -perl -python -ruby -tiff -vala -vulkan -zink X acpi alsa apparmor bluetooth cjk cpu_flags_x86_aes cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_mmx cpu_flags_x86_mmxext cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 cpu_flags_x86_sse4_1 cpu_flags_x86_sse4_2 cpu_flags_x86_ssse3 curl dbus dist-kernel elogind fcitx4 gles2 input_devices_libinput input_devices_synaptics jpeg lapack lm-sensors lzma opengl openh264 pulseaudio -system-mitkrb5 udev unicode v4l vaapi video_cards_amdgpu video_cards_i915 video_cards_intel video_cards_nouveau video_cards_radeon video_cards_radeonsi vim-syntax wayland webp xinerama"' | cat >> /etc/portage/make.conf
RUN echo 'ACCEPT_LICENSE="@BINARY-REDISTRIBUTABLE"' | cat >> /etc/portage/make.conf

RUN emerge-webrsync -q && emerge -qDNu @world dev-vcs/git

RUN cd /etc/portage && git init && git remote add origin https://github.com/hkbu-kennycheng/etc-portage-x32 && git fetch origin && git checkout -b main -t origin/main

RUN echo 'app-crypt/mit-krb5' | cat >> /etc/portage/package.mask/mit-krb5

RUN echo 'app-backup/mkstage4 ~amd64' | cat >> /etc/portage/package.accept_keywords/mkstage4
RUN echo 'app-mobilephone/scrcpy ~amd64' | cat >> /etc/portage/package.accept_keywords/scrcpy
RUN echo 'games-arcade/opensonic ~amd64' | cat >> /etc/portage/package.accept_keywords/opensonic
RUN echo 'net-fs/smbnetfs ~amd64' | cat >> /etc/portage/package.accept_keywords/smbnetfs
RUN echo 'gnome-base/librsvg **' | cat >> /etc/portage/package.accept_keywords/librsvg

RUN echo 'app-containers/waydroid ~amd64' | cat >> /etc/portage/package.accept_keywords/waydroid
RUN echo 'dev-python/gbinder ~amd64' | cat >> /etc/portage/package.accept_keywords/waydroid
RUN echo 'dev-python/pyclip ~amd64' | cat >> /etc/portage/package.accept_keywords/waydroid
RUN echo 'dev-libs/libglibutil ~amd64' | cat >> /etc/portage/package.accept_keywords/waydroid
RUN echo 'dev-libs/gbinder ~amd64' | cat >> /etc/portage/package.accept_keywords/waydroid

RUN echo 'app-containers/waydroid -apparmor' | cat >> /etc/portage/package.use/waydroid
RUN echo 'app-crypt/gcr gtk' | cat >> /etc/portage/package.use/gcr
RUN echo 'media-libs/harfbuzz icu' | cat >> /etc/portage/package.use/harfbuzz
RUN echo 'app-text/poppler cairo' | cat >> /etc/portage/package.use/poppler
RUN echo 'media-libs/gegl cairo' | cat >> /etc/portage/package.use/gegl
RUN echo 'media-libs/allegro vorbis png' | cat >> /etc/portage/package.use/allegro
RUN echo 'sys-libs/libcap static-libs' | cat >> /etc/portage/package.use/libcap
RUN echo 'virtual/imagemagick-tools tiff' | cat >> /etc/portage/package.use/imagemagick
RUN echo 'media-gfx/imagemagick tiff' | cat >> /etc/portage/package.use/imagemagick
RUN echo 'media-sound/mpg123 -pulseaudio' | cat >> /etc/portage/package.use/mpg123

RUN emerge -q app-containers/docker app-containers/docker-cli app-backup/mkstage4 app-admin/metalog app-containers/lxc app-editors/vim app-eselect/eselect-java app-eselect/eselect-repository app-i18n/fcitx app-i18n/fcitx-configtool app-i18n/fcitx-table-extra app-laptop/laptop-mode-tools app-misc/asciinema app-misc/jq app-misc/tmux app-mobilephone/scrcpy app-portage/gentoolkit app-text/mupdf dev-java/openjdk-bin dev-libs/weston dev-python/dbus-python dev-python/numpy dev-python/pandas dev-python/pip dev-python/seaborn dev-util/android-tools dev-util/debootstrap dev-vcs/git games-arcade/opensonic media-fonts/noto media-gfx/feh media-gfx/gimp media-sound/alsa-utils media-sound/pamix media-video/mpv net-analyzer/speedtest-cli net-fs/smbnetfs net-fs/sshfs net-misc/aria2 net-misc/dhcpcd net-misc/tigervnc net-misc/yt-dlp net-wireless/iwd net-wireless/wpa_supplicant sci-libs/scikit-learn sys-apps/busybox sys-apps/pciutils sys-apps/usbutils sys-block/parted sys-firmware/sof-firmware sys-fs/bcache-tools sys-fs/btrfs-progs sys-kernel/linux-firmware sys-kernel/genkernel sys-kernel/gentoo-kernel-bin sys-process/htop www-client/surf x11-apps/xev x11-apps/xhost x11-apps/xinput x11-apps/xrandr x11-apps/xsetroot x11-apps/xwd x11-base/xorg-server x11-misc/dmenu x11-misc/slock x11-misc/xautolock x11-misc/xclip x11-terms/st x11-wm/dwm
