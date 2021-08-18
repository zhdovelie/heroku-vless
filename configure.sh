#!/bin/sh

# Download and install V2Ray
mkdir /tmp/v2ray
curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl
v2ray -version

# Remove temporary directory
rm -rf /tmp/v2ray

# Acme cert generation
acme.sh --issue -d herokuapp.com -d '*.herokuapp.com' --dns dns_cf
acme.sh --installcert -d herokuapp.com -d '*.herokuapp.com' \
        --ca-file /usr/share/caddy/cert.ca \
        --cert-file /usr/share/caddy/cert.crt \
        --key-file /usr/share/caddy/cert.key \
        --fullchain-file /usr/share/caddy/cert.pem
acme.sh --upgrade --auto-upgrade

# XRay new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {   
            "listen": "/etc/caddy/vless",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$ID",
                        "flow": "xtls-rprx-direct",
                        "level": 0,
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$ID-vless"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

# Config Caddy
mkdir -p /etc/caddy/ /usr/share/caddy/ && echo -e "User-agent: *\Disallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$ID/$ID/g" -e "s/\$API_KEY/$API_KEY/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g" >/etc/caddy/Caddyfile

# Run XRay
tor & /usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json & /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
