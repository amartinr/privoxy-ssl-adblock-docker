#!/bin/bash
set -e
CA_CERT=/usr/local/etc/privoxy/CA/privoxy-ca-bundle.crt
CA_KEY=/usr/local/etc/privoxy/CA/cakey.pem

function create_cert() {
    openssl req -nodes  -new -x509 -extensions v3_ca \
        -keyout $CA_KEY \
        -out $CA_CERT -days 3650 \
        -subj "/C=ZZ/ST=Unknown/O=${CERT_ORG}/CN=*/emailAddress=${CERT_EMAIL}" >& /dev/null && \
    openssl x509 -in $CA_CERT -noout -text
    cat $CA_CERT
}

[ -f ${CA_CERT} ] && [ -f ${CA_KEY} ] || create_cert

/usr/local/bin/privoxy-blocklist.sh \
    -c /usr/local/etc/privoxy-blocklist/privoxy-blocklist.conf

/usr/local/sbin/privoxy --no-daemon /usr/local/etc/privoxy/config
#exec "$@"
