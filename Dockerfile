FROM caddy:builder-alpine AS builder

RUN xcaddy build \
        --with github.com/mholt/caddy-l4 \
        --with github.com/ueffel/caddy-brotli \
        --with github.com/casbin/caddy-authz \
        --with github.com/greenpau/caddy-auth-portal \
        --with github.com/greenpau/caddy-auth-jwt \
        --with github.com/ss098/certmagic-s3 \
        --with github.com/silinternational/certmagic-storage-dynamodb \
        --with github.com/pteich/caddy-tlsconsul \
        --with github.com/caddy-dns/cloudflare
        
FROM caddy:builder-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk update && \
    apk add --no-cache  ca-certificates curl unzip wget tor nss-tools

ENV XDG_CONFIG_HOME /etc/caddy
ENV XDG_DATA_HOME /usr/share/caddy

COPY etc/Caddyfile /conf/Caddyfile
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
