### Nginx CORS 
Allow `http(s)://47.92.6.114:8000` or `http(s)://www.my-cn.com` or `http(s)://my-cn.com` to access this domain.

```bash
location /api/submissions/ {
    set $cors '';  # variable
    if ($http_origin ~* 'https?:\/\/(47\.92\.6\.114:8000|www\.my\-cn\.com|my\-cn\.com)') {
        set $cors 'true';
    }

    if ($request_method = 'OPTIONS') {
        set $cors "${cors}options"; # internal variable
    }
    if ($request_method = 'GET') {
        set $cors "${cors}get";
    }

    if ($cors = "true") { # exact matching
        # Catch all incase there's a request method we're not dealing with properly
        add_header 'Access-Control-Allow-Origin' "$http_origin";
    }
    # this section can't be merged with next section
    if ($cors ~* "trueoptions") {  # case-insensitive regex matching
        add_header 'Access-Control-Allow-Origin' "$http_origin";
        add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        return 204;
    }
    # this section can't be merged with the above section 
    if ($cors = "trueget") { 
        add_header 'Access-Control-Allow-Origin' "$http_origin";
        add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    }
    # more config come here.....
}
```
More about Nginx Regex and if matching: 
- https://www.regextester.com/94055
- http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#if 

### Basic Auth
1. generate password
```bash
echo -n 'user1:' >> /etc/nginx/.htpasswd
openssl passwd -apr1 >> /etc/nginx/.htpasswd # type password1 here
chmod 600 /etc/nginx/.htpasswd 
```

2. setup authenticate area
```bash
server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /usr/share/nginx/html;
    index index.html index.htm;

    server_name localhost;

    location / {
        try_files $uri $uri/ =404;
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

### Basic at the proxy server side
NOTE for base64
Also, for Nginx, base64 is a little different, e.g,
```bash
09:12 PM root@localhost:~# echo 'king:isnaked' |base64 
a2luZzppc25ha2VkCg==
```
`However`, in Nginx, we have to use `a2luZzppc25ha2Vk` instead of `a2luZzppc25ha2VkCg==`. 
Actually, I can change the last `g` to any chars, next can all be decoded to `king:isnaked`
```bash
09:14 PM root@localhost:~# for i in {a..z}; do echo "a2luZzppc25ha2VkC$i==" | base64 -d;done
king:isnaked	king:isnaked	king:isnaked	king:isnaked	king:isnaked	king:isnaked	king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
king:isnaked
            king:isnaked
                        king:isnaked
                                    king:isnaked
                                                09:14 PM root@localhost:~# 
09:14 PM root@db-master:~# for i in {A..Z}; do echo "a2luZzppc25ha2VkC$i==" | base64 -d;done
king:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnakeking:isnaked	king:isnakeking:isnaked	king:isnaked	king:isnaked	king:isnaked	king:isnaked	king:isnaked	king:isnaked	king:isnaked	09:15 PM root@db-master:~# 
```
Full config: 
```bash
 location / {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://6.6.6.6:80;
    proxy_set_header Authorization "Basic a2luZzppc25ha2Vk";
 }
```
`proxy_set_header Authorization "Basic a2luZzppc25ha2Vk";` is very important!!!
`a2luZzppc25ha2Vk` is the base64 encoding for `king:isnaked`


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
Here is the Makefile to generate SSL Certificate: 
```Makefile
SERVER-HOST=foo.bar.com
CLIENT-HOST=morgan-yinnut.local

SERVER_SIGNED_BY_CA=true
define NEWLINE=

endef

all: prepare ca client server

prepare:
        @echo "step1. generate ca,client,server,conf directory..."
        @echo "===================================================="
        [[ -e ca ]] || mkdir ca client server conf

        echo [req] > conf/openssl.conf
        echo req_extensions = v3_req >> conf/openssl.conf
        echo distinguished_name = req_distinguished_name >> conf/openssl.conf
        echo [req_distinguished_name] >> conf/openssl.conf
        echo [ v3_req ] >> conf/openssl.conf
        echo basicConstraints = CA:FALSE >> conf/openssl.conf
        echo keyUsage = nonRepudiation, digitalSignature, keyEncipherment >> conf/openssl.conf

        echo authorityKeyIdentifier=keyid,issuer > conf/v3.ext
        echo basicConstraints=CA:FALSE >> conf/v3.ext
        echo keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment >> conf/v3.ext
        echo subjectAltName = @alt_names >> conf/v3.ext
        echo "" >> conf/v3.ext
        echo [alt_names] >> conf/v3.ext
        echo DNS.1 = $(SERVER-HOST) >> conf/v3.ext

ca: prepare
        @echo "$(NEWLINE)"
        @echo "step2. generate CA ..."
        @echo "===================================================="
        [[ -e ca/ca.key ]] || openssl genrsa -out ca/ca.key 2048
        [[ -e ca/ca.crt ]] || openssl req -x509 -new -nodes -key ca/ca.key -days 10000 -out ca/ca.crt -subj "/CN=example-ca"

client: prepare ca
        @echo "$(NEWLINE)"
        @echo "===================================================="
        @echo "step3. generate client key/certificate ..."
        openssl genrsa -out client/client1.key 2048
        openssl req -new -key client/client1.key -out client/client1.csr -subj "/CN=$(CLIENT-HOST)" -config conf/openssl.conf
        openssl x509 -req -in client/client1.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial -out client/client1.crt -days 365 -extfile conf/v3.ext -sha256
        openssl pkcs12 -export -clcerts -in client/client1.crt -inkey client/client1.key -password pass:123456 -out client/client1.p12

server: prepare
        @echo "$(NEWLINE)"
        @echo "===================================================="
        @echo "step4. generate server key/certificate ..."
ifeq ($(SERVER_SIGNED_BY_CA), false)
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server/tls.key -out server/tls.crt -subj "/CN=$(SERVER-HOST)"
else
        openssl genrsa -out server/tls.key 2048
        openssl req -new -key server/tls.key -out server/tls.csr -subj "/CN=$(SERVER-HOST)" -config conf/openssl.conf
        openssl x509 -req -in server/tls.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial -out server/tls.crt -days 365 -extfile conf/v3.ext -sha256
endif
        openssl pkcs12 -export -clcerts -in server/tls.crt -inkey server/tls.key -password pass:123456 -out server/tls.p12

clean:
        rm -rf server client ca conf
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


### OpenResty 
https://moonbingbing.gitbooks.io/openresty-best-practices/
