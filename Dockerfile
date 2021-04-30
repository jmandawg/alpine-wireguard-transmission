FROM alpine:latest

COPY . /
RUN apk add --update netcat-openbsd gettext curl wireguard-tools transmission-daemon && rm -rf /var/cache/apk && chmod 755 startup.sh

EXPOSE 9091/tcp

VOLUME /data

ENTRYPOINT ["./startup.sh"]

