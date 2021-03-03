#!/bin/sh

# Download and install XRay
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
xray -v

# Download and install Trojan-go
mkdir /tmp/trojan
curl -L -H "Cache-Control: no-cache" -o /tmp/trojan/trojan.zip https://github.com/p4gefau1t/trojan-go/releases/download/v0.8.2/trojan-go-linux-amd64.zip
unzip /tmp/trojan/trojan.zip -d /tmp/trojan
install -m 755 /tmp/trojan/trojan-go /usr/local/bin/trojan-go
trojan-go -v

# Remove temporary directory
rm -rf /tmp/xray
rm -rf /tmp/trojan

# XRay new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
    "inbounds": [
        {
            "port": $PORT,
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

# Trojan-go new configuration
install -d /usr/local/etc/trojan-go
cat << EOF > /usr/local/etc/trojan-go/config.json
{
    "inbounds": [
        {
            "port": $PORT,
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "$ID"
                    }
                ],
                "decryption": "none"
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

# Run XRay
/usr/local/bin/xray -config /usr/local/etc/xray/config.json

# Run Trojan-go
/usr/local/bin/trojan-go -config /usr/local/etc/trojan-go/config.json
