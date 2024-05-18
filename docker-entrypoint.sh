#! /bin/sh

set -euo pipefail

export RESOLVER_IP=$(nslookup pdns | grep Address | tail -1 | sed 's/Address:\s\+//g')

# Create config file from template
envtpl </recursor.conf.tpl >/etc/pdns/recursor.conf
sed -i 's/RESOLVER_IP/'$RESOLVER_IP'/g' /etc/pdns/recursor.conf

# Fix config file ownership
chown ${PDNS_setuid}:${PDNS_setgid} /etc/pdns/recursor.conf

exec "$@"
