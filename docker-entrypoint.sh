#! /bin/sh

set -euo pipefail

# Configure base vars
: "${PDNS_local_port:=53}"
: "${PDNS_local_address:=0.0.0.0}"
: "${PDNS_allow_from:=0.0.0.0/0}"

export PDNS_local_port PDNS_local_address PDNS_allow_from

export RESOLVER_IP=$(nslookup pdns | grep Address | tail -1 | sed 's/Address:\s\+//g')

config_file=/etc/pdns/recursor.conf
pdns_user=recursor

# Create config file from template
envtpl < /recursor.conf.tpl > $config_file
sed -i 's/RESOLVER_IP/'$RESOLVER_IP'/g' $config_file

# Fix config file ownership
chown ${pdns_user}: $config_file

exec "$@"

