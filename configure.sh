#!/bin/sh

# Get V2/X2 binary and decompress binary
mkdir /tmp/v2ray
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o /tmp/v2ray/v2ray.zip
busybox unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl
v2ray -version
rm -rf /tmp/v2ray

# Install geoip
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL raw.githubusercontent.com/Loyalsoldier/geoip/release/cn.dat -o /usr/local/bin/cn.dat

# V2/X2 new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {   
            "port": ${PORT},
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$ID",
                        "level": 0,
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$ID-vless"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                     "http",
                     "tls"
                ]
            }
        },
        {   
            "port": ${PORT},
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password":"$ID",
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$ID-trojan"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                     "http",
                     "tls"
                ]
            }
        }
    ],
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "domainMatcher": "mph",
        "rules": [
           {
              "type": "field",
              "protocol": [
                 "bittorrent"
              ],
              "ip": [
                  "ext:cn.dat:cn"
              ],
              "inboundTag": "cn",
              "outboundTag": "cn"
           }
        ]
    },
    "outbounds": [
        {
            "tag": "cn",
            "protocol": "blackhole"
        },
        {
            "protocol": "freedom"
        }
    ],
    "dns": {
        "servers": [
            "https://dns.google/dns-query",
            "https://cloudflare-dns.com/dns-query"
        ]
    }
}
EOF

# Run V2/X2
/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
