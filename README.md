# heroku-vless
Deploy VLESS server to heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/Dimitri2020007/heroku-vless/tree/main)

# Vmess/VLESS Client Setup

| Connection Variables | Values |
| -------------------- | ------ |
| `Address` | yourAppName.herokuapp.com </br> Cloudflare Reverse Proxy Address |
| `SNI` | Same of Address |
| `AllowInsecure` | false |
| `Port` | 443 |
| `Path` | /$ID-vless |
| `id` | Use UUID Generator |
| `Flow` | xtls-rprx-direct |
| `encryption` | none |
| `Transport` | ws |
| `Security` | tls |

# Client Ws+Tls+Xtls-rprx-direct(Flow) Support Status

| Client | Status |
| ------ | ------ |
| `2dust V2RayN` </br> `2dust V2RayNG` | Yes |
| `OpenWrt SSRPlus` | No |
| `OpenWrt Passwall` | No |
| `QV2Ray` | No |

# Cloudflare Reverse Proxy Code
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
        url.pathname="/$ID-vless";
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
