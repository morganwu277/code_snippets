### Stats about top 20 requsts IP Address
```bash
root@xxxx:/var/log/nginx# cat /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c |sort -k1n | tail -20
   5266 157.55.39.166
   5428 157.55.39.69
   5630 207.46.13.22
   6952 116.66.184.172
   7262 212.252.206.35
   7484 216.145.126.117
   7808 221.226.97.25
   8251 116.66.184.173
   8678 103.218.216.113
   9269 118.163.170.73
  10461 66.249.79.156
  10861 115.236.50.18
  10945 171.161.160.10
  12594 77.88.5.16
  15187 58.213.108.68
  17264 171.159.192.10
  23064 77.88.5.63
  24249 54.92.192.45
  28311 5.255.250.134
  31182 88.198.158.233
```

### Create SSL certificates 
```bash
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
```
For new certificate signed by self-signed CA. https://medium.com/@kennychen_49868/chrome-58%E4%B8%8D%E5%85%81%E8%A8%B1%E6%B2%92%E6%9C%89san%E7%9A%84%E8%87%AA%E7%B0%BD%E6%86%91%E8%AD%89-12ca7029a933 
 and https://imququ.com/post/sth-about-switch-to-https-2.html 


### Nginx Performance Recommendation
https://www.linode.com/docs/web-servers/nginx/configure-nginx-for-optimized-performance

### Deploy http & https website best-practice
```bash
upstream today {
    ip_hash;
    server me-app-1:8181 weight=5 fail_timeout=5s max_fails=5;

    # for tcp higher performance
    keepalive 60; 
}

server {
    listen       443 ssl;
    server_name  myeffect.today;
    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    location / {
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
        proxy_pass http://today;
    }
}

server {
    listen       80;
    listen       [::]:80;
    server_name  myeffect.today;
    # for redirecting all http requetst to SSL version
    return       301 https://$server_name$request_uri;
}

# however for production.myeffect.today, we don't enable redirect features.
server {
    listen       80;
    listen       [::]:80;
    listen       443 ssl;
    server_name production.myeffect.today;
    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    location / {
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
        proxy_pass http://today;
    }

#    location /assets {
#        alias /path/to/assets;
#        access_log off;
#        expires max;
#    }
}
```
### Optimization 
1. https://www.sysgeek.cn/nginx-optimized-performance/ 
2. http://www.360doc.com/content/10/0106/11/11991_12790368.shtml 
3. https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration  
