FROM alpine:edge

RUN apk add --no-cache \
    pdns-recursor=5.0.3-r0 \
    && apk add --no-cache --virtual .build-deps curl \
    && curl -L https://github.com/matt-allan/envtpl/releases/download/0.4.0/x86_64-linux.tar.xz | tar -xJ --strip-components=1 -C /usr/local/bin/ \
    && apk del .build-deps

RUN mkdir -p /etc/pdns/api.d \
  && chown -R recursor: /etc/pdns/api.d \
  && mkdir -p /var/run/pdns-recursor \
  && chown -R recursor: /var/run/pdns-recursor

ENV VERSION=5.3 \
  PDNS_setuid=recursor \
  PDNS_setgid=recursor \
  PDNS_daemon=no

EXPOSE 53 53/udp

COPY recursor.conf.tpl /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/usr/sbin/pdns_recursor" ]
