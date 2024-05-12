FROM alpine:edge as build-stage

# Install Python
ARG PYTHON_VERSION=3.12.3
RUN apk add \
    wget \
    gcc \
    make \
    zlib-dev \
    libffi-dev \
    openssl-dev \
    musl-dev \
    && cd /tmp \
    && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar xzf Python-${PYTHON_VERSION}.tgz \
    && cd /tmp/Python-${PYTHON_VERSION} \
    && ./configure --prefix=/usr --enable-shared --enable-optimizations --with-ensurepip=install \
    && make install

# Install envtpl
ENV PATH "/opt/venv/bin:$PATH"
RUN apk add \
    binutils \
    libffi-dev \
    && python3 -m venv /opt/venv \
    && pip3 install --no-cache-dir envtpl pyinstaller \
    && pyinstaller -F /opt/venv/lib/python3.12/site-packages/envtpl.py

FROM alpine:edge

COPY --from=build-stage --chown=root:root /dist/envtpl /usr/local/bin/

RUN apk add --no-cache \
    pdns-recursor=5.0.4-r0

RUN mkdir -p /etc/pdns/api.d \
  && chown -R recursor: /etc/pdns/api.d \
  && mkdir -p /var/run/pdns-recursor \
  && chown -R recursor: /var/run/pdns-recursor

ENV VERSION=5.0 \
  PDNS_setuid=recursor \
  PDNS_setgid=recursor \
  PDNS_daemon=no

EXPOSE 53 53/udp

COPY recursor.conf.tpl /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/usr/sbin/pdns_recursor" ]
