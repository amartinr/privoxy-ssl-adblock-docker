FROM alpine:latest

# Create Privoxy User
RUN set -eux; \
    adduser \
        -D \
        -h /usr/local/etc/privoxy \
        -G nogroup \
        -H \
        -S \
        -u 109 \
        privoxy; \
    mkdir -p /var/local/lib/privoxy/certs; \
    chown privoxy /var/local/lib/privoxy/certs; \
    chmod 750 /var/local/lib/privoxy/certs;

# Install build related stuff
RUN set -eux; \
    apk add --no-cache --virtual build-tools \
        gcc \
        autoconf \
        make \
        git; \
    apk add --no-cache --virtual build-deps \
        libc-dev \
        zlib-dev \
        pcre-dev \
        openssl-dev \
        brotli-dev;

ARG PRIVOXY_VERSION=3.0.34
ARG PRIVOXY_GIT_TAG=v_3_0_34

# Build Privoxy
RUN set -eux; \
    git clone -b ${PRIVOXY_GIT_TAG} https://www.privoxy.org/git/privoxy.git /usr/local/src/privoxy-${PRIVOXY_VERSION};
RUN set -eux; \
    cd /usr/local/src/privoxy-${PRIVOXY_VERSION}; \
    autoheader; \
    autoconf; \
    ./configure --disable-toggle --disable-editor --disable-force --with-openssl --with-brotli; \
    make; \
    make -s install USER=privoxy GROUP=nogroup; \
    rm -rf /usr/local/src/privoxy-${PRIVOXY_VERSION}; \
    apk del build-tools;

# Add system tools
RUN set -eux; \
    apk add --no-cache openssl ca-certificates bash sed;

# Enable Privoxy HTTPS inspection
RUN set -eux; \
    mv /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.orig; \
    sed -i '/^+set-image-blocker{pattern}/a +https-inspection \\' /usr/local/etc/privoxy/match-all.action;

# Copy project scripts/configs
COPY conf/config /usr/local/etc/privoxy/
COPY conf/privoxy-blocklist.conf conf/adblock-dyn.conf /usr/local/etc/privoxy-blocklist/
#ADD https://github.com/Andrwe/privoxy-blocklist/releases/download/0.4.0/privoxy-blocklist.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/Andrwe/privoxy-blocklist/main/privoxy-blocklist.sh /usr/local/bin/
RUN sed -i -r "181,185s/^/#/" /usr/local/bin/privoxy-blocklist.sh
COPY bin/docker-entrypoint.sh /usr/local/bin/

# Set the correct permissions
RUN set -eux; \
    mkdir -p /usr/local/etc/privoxy/CA /var/local/etc/privoxy/certs; \
    update-ca-certificates && ln -s /etc/ssl/certs/ca-certificates.crt /usr/local/etc/privoxy/CA/trustedCAs.pem; \
    chown -R privoxy /usr/local/etc/privoxy /usr/local/etc/privoxy/CA /var/local/etc/privoxy/certs; \
    chmod 755 /usr/local/bin/docker-entrypoint.sh /usr/local/bin/privoxy-blocklist.sh;

ENV ADBLOCK_URLS="${ADBLOCK_URLS:-https://easylist.to/easylist/easylist.txt}" \
    ADBLOCK_FILTERS="" \
    CERT_EMAIL="${CERT_EMAIL:-webmaster@example.com}" \
    CERT_ORG="${CERT_ORG:-Example}"

USER privoxy
WORKDIR /usr/local/etc/privoxy
ENTRYPOINT ["docker-entrypoint.sh"]
