#!/bin/sh

# Download and install XRay
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
xray -version

# Download and install ACME
curl https://get.acme.sh | sh -s email=$EMAIL

# Remove xray temporary directory
rm -rf /tmp/xray

# XRay new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
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
                  "path": "/$ID-vless?ed=2048"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ],
    "dns": {
        "servers": [
            "1.1.1.1"
        ]
    }
}
EOF

# Config Caddy
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$APPNAME/$APPNAME/g" -e "s/\$ID/$ID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g" >/etc/caddy/Caddyfile

# Config ACME
acme.sh --issue -d $APPNAME.herokuapp.com --webroot /usr/share/caddy
acme.sh --install-cert -d $APPNAME.herokuapp.com --cert-file /usr/share/caddy/cert.crt --key-file /usr/share/caddy/cert.key
acme.sh --upgrade --auto-upgrade

# Run XRay
tor & /usr/local/bin/xray -config /usr/local/etc/xray/config.json & caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
