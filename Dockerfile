FROM alpine:latest

COPY . /
ENV WG_ALLOWED_IPS="0.0.0.0/0, ::/0"
RUN apk add --update openssh netcat-openbsd gettext curl iptables wireguard-tools transmission-daemon && rm -rf /var/cache/apk && chmod 755 startup.sh

EXPOSE 9091/tcp
EXPOSE 22/tcp

VOLUME /data

ENTRYPOINT ["./startup.sh"]

