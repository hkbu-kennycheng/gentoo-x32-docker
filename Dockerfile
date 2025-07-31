FROM docker.io/kennycheng/gentoo-stage4:x32-systemd

ADD entrypoint.sh /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["sh", "/entrypoint.sh"]
