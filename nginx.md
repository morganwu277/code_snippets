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
