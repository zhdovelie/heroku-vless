#!/bin/sh

# Download and install XRay
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
xray -version

# Remove temporary directory
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

# Config Nginx
mkdir -p /etc/nginx /usr/share/nginx && echo -e "User-agent: *\nDisallow: /" >/usr/share/nginx/robots.txt
wget $NGINXIndexPage -O /usr/share/nginx/index.html && unzip -qo /usr/share/nginx/index.html -d /usr/share/nginx/ && mv /usr/share/nginx/*/* /usr/share/nginx/
wget -qO- $CONFIGNGINX | sed -e "1c :$PORT" -e "s/\$ID/$ID/g" >/etc/nginx/nginx.conf

# Run XRay
tor & /usr/local/bin/xray -config /usr/local/etc/xray/config.json & nginx -g 'daemon off;'
