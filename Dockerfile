FROM alpine:3.19

RUN apk add --no-cache \
    pdns-recursor=4.9.2-r0 \
    py3-pip \
    python3

ENV PATH "/opt/venv/bin:$PATH"

RUN python3 -m venv /opt/venv \
    && pip3 install --no-cache-dir envtpl

RUN mkdir -p /etc/pdns/api.d \
  && chown -R recursor: /etc/pdns/api.d \
  && mkdir -p /var/run/pdns-recursor \
  && chown -R recursor: /var/run/pdns-recursor

ENV VERSION=4.9 \
  PDNS_setuid=recursor \
  PDNS_setgid=recursor \
  PDNS_daemon=no

EXPOSE 53 53/udp

COPY recursor.conf.tpl /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/usr/sbin/pdns_recursor" ]
