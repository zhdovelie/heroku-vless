# heroku-vless
Deploy VLESS server to heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/Dimitri2020007/heroku-vless/tree/main)

# Vmess/VLESS Client Setup

| Connection Variables | Values |
| -------------------- | ------ |
| `Address` | yourAppName.herokuapp.com </br> Cloudflare Reverse Proxy IP |
| `SNI` | Same as Host |
| `AllowInsecure` | false |
| `Port` | 443 |
| `Host` | yourAppName.herokuapp.com </br> Cloudflare Reverse Proxy Domain Name |
| `Path` | /$ID-vless?ed=2048 |
| `id` | Generate using UUID generator |
| `Flow` | xtls-rprx-direct |
| `encryption` | none |
| `Transport` | ws |
| `Tls` | Tls must open, otherwise you will be disconnected |

# Client Ws+Tls+Xtls-rprx-direct(Flow) Support Status

| Client | Status |
| ------ | ------ |
| `2dust V2RayN` </br> `2dust V2RayNG` | Ws+Tls+Flow |
| `OpenWrt SSRPlus` | Ws+Tls |
| `OpenWrt Passwall` | Ws+Tls |
| `QV2Ray` | Ws+Tls |

# Cloudflare Reverse Proxy Code

```
const SingleDay = 'appname.herokuapp.com'
const DoubleDay = 'appname.herokuapp.com'
addEventListener(
    "fetch",event => {
    
        let nd = new Date();
        if (nd.getDate()%2) {
            host = SingleDay
        } else {
            host = DoubleDay
        }
        
        let url=new URL(event.request.url);
        url.hostname="appname.herokuapp.com";
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```

# Acknowledgments

- [Project V](https://github.com/v2ray/v2ray-core.git)
- [Project X](https://github.com/XTLS/Xray-core.git)
- [HeroKu](https://heroku.com)
- [heroku-vless](https://github.com/DanyTPG/heroku-vless.git)
- [Better Cloudflare IP](https://github.com/XIU2/CloudflareSpeedTest.git)

# New Features

Websocket 0-RTT import (Just add at the end of path /examples?ed=2048)

Client and Server Xray-core 1.4.0+ required!!

Support caddy reverse proxy

# 重要信息
新用户只需要修改id即可

不熟悉caddy配置的不要修改caddy配置

严禁滥用，因滥用出现的所有问题本人概不负责，且用且珍惜！

本项目不宜做为长期翻墙使用。

出于安全考量，请使用cdn，不要使用自定义域名，以实现VLESS+WS+TLS。
