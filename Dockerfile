FROM kennycheng/gentoo-stage4:x32-systemd

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT /entrypoint.sh
