FROM docker.io/kennycheng/gentoo-stage4:x32-systemd

ARG MAKEOPTS
ARG EMERGE_DEFAULT_OPTS

RUN emerge-webrsync && emerge --sync x32-overlay

RUN echo "dev-libs/libdbusmenu gtk3" >> /etc/portage/package.use/libdbusmenu \
    && echo "xfce-base/thunar udisks" >> /etc/portage/package.use/thunar \
    && echo "gnome-base/gvfs udisks" >> /etc/portage/package.use/gvfs \
    && echo "sys-apps/systemd policykit" >> /etc/portage/package.use/systemd \
    && echo "dev-libs/glib introspection" >> /etc/portage/package.use/glib \
    && echo "net-misc/networkmanager dhcpcd" >> /etc/portage/package.use/networkmanager \
    && echo "gui-libs/libwlembed gtk" >> /etc/portage/package.use/libwlembed

RUN emerge --quiet --noreplace \
    xfce-base/xfce4-meta \
    net-misc/networkmanager \
    gnome-extra/nm-applet \
    && rm -rf /var/cache/distfiles/*

# Set the optimization flags to optimize for size instead of speed to allow webkit-gtk to compile on a 32-bit system with limited memory.
RUN sed -i 's/COMMON_FLAGS="-O2 -pipe/COMMON_FLAGS="-Os -pipe/g' /etc/portage/make.conf \
    && emerge --quiet --noreplace www-client/surf \
    && rm -rf /var/cache/distfiles/* \
    && sed -i 's/COMMON_FLAGS="-Os -pipe/COMMON_FLAGS="-O2 -pipe/g' /etc/portage/make.conf
