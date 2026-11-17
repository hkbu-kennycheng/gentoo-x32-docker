FROM docker.io/kennycheng/gentoo-stage4:x32-systemd

ARG MAKEOPTS
ARG EMERGE_DEFAULT_OPTS

RUN echo "dev-libs/libdbusmenu gtk3" >> /etc/portage/package.use/libdbusmenu \
    && echo "xfce-base/thunar udisks" >> /etc/portage/package.use/thunar \
    && echo "gnome-base/gvfs udisks" >> /etc/portage/package.use/gvfs \
    && echo "sys-apps/systemd policykit" >> /etc/portage/package.use/systemd \
    && echo "dev-libs/glib introspection" >> /etc/portage/package.use/glib \
    && echo "net-misc/networkmanager dhcpcd" >> /etc/portage/package.use/networkmanager

RUN emerge --quiet --noreplace \
    xfce-base/xfce4-meta \
    net-misc/networkmanager \
    gnome-extra/nm-applet \
    && rm -rf /var/cache/distfiles/*
