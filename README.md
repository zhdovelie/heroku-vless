# heroku-vless
Deploy VLESS server to heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/Dimitri2020007/heroku-vless/tree/main)

| Connection Variables | Values |
| -------------------- | ------ |
| Address | yourAppName.herokuapp.com </br> Cloudflare Reverse Proxy Address |
| AllowInsecure | false |
| Port | 443 |
| Path | /$ID-vless |
| id | Use UUID Generator |
| Flow | xtls-rprx-direct |
| encryption | none |
| Transport | ws |
| Security | tls |

| ws+tls+flow supported | success | failed |
| --------------------- | ------- | ------ |
| 2dust/v2rayn/v2rayng  | yes | - |
| openwrt ssrplus | - | yes |
| openwrt passwall | - | yes |
| QV2Ray | n/a | n/a |

Cloudflare Reverse Proxy Code
```
const SingleDay = 'yourAppName.herokuapp.com'
const DoubleDay = 'yourAppName.herokuapp.com'
addEventListener(
    "fetch",event => {
    
        let nd = new Date();
        if (nd.getDate()%2) {
            host = SingleDay
        } else {
            host = DoubleDay
        }
        
        let url=new URL(event.request.url);
        url.hostname="yourAppName.herokuapp.com";
        url.pathname="/id-vless";
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
