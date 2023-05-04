FROM alpine:latest

COPY . /
ENV WG_ALLOWED_IPS="0.0.0.0/0, ::/0"
RUN apk add --update netcat-openbsd gettext curl wireguard-tools transmission-daemon && rm -rf /var/cache/apk && chmod 755 startup.sh

EXPOSE 9091/tcp

VOLUME /data

ENTRYPOINT ["./startup.sh"]

