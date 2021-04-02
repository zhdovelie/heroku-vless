#!/bin/sh

# Download and install XRay
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
xray -version

# Remove xray temporary directory
rm -rf /tmp/xray

# XRay new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
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
    ]
}
EOF

# Download and install Trojan-go
mkdir /tmp/trojango
curl -L -H "Cache-Control: no-cache" -o /tmp/trojango/trojan-go.zip https://github.com/p4gefau1t/trojan-go/releases/download/v0.8.3/trojan-go-linux-amd64.zip
unzip /tmp/trojango/trojan-go.zip -d /tmp/trojango
install -m 755 /tmp/trojango/trojan-go /usr/local/bin/trojan-go
trojan-go -version

# Remove trojan-go temporary directory
rm -rf /tmp/trojango

# Trojan-go new configuration
install -d /usr/local/etc/trojan-go
cat << EOF > /usr/local/etc/trojan-go/config.json
{
    "inbounds": [
        {
            "listen": "/etc/caddy/trojan",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "$ID"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                  "path": "/$ID-trojan"
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
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$ID/$ID/g" >/etc/caddy/Caddyfile

# Run XRay
tor & /usr/local/bin/xray -config /usr/local/etc/xray/config.json & /usr/local/bin/trojan-go -config /usr/local/etc/trojan-go/config.json & caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
