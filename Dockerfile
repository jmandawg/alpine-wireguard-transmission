FROM alpine:latest

COPY . /
RUN apk add --update netcat-openbsd curl wireguard-tools transmission-daemon; chmod 755 startup.sh

EXPOSE 9091/tcp

VOLUME /data

ENTRYPOINT ["./startup.sh"]

