### Create SSL certificates 
```bash
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
```
### Deploy http & https website best-practice
```bash
upstream today {
    ip_hash;
    server me-app-1:8181 weight=5;

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