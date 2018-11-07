### Nginx subdirectory Easy Setup
```bash
        location /buildlog {
            alias /home/morganwu/xxx/src_root/buildlog; # need a+rx permission for every ancestor directory 
            autoindex on; # list the directories
            autoindex_exact_size off; # using the human size
            autoindex_format html; 
            autoindex_localtime on; # don't use UTC, but local time
            disable_symlinks off; # enable symbol link
            location ~ /buildlog/bld.* {
               add_header Content-Type text/plain; # assume them all as text/plain files
            }
        }
```
Ref: https://www.keycdn.com/support/nginx-directory-index 
This is an easy example for how do we expose `/buildlog` to external, using `http://{IP}/buildlog` to access this directory. 

However, we need `a+rx` permission on every parent directory of buildlog, until above the `/` directory if nginx process user is different from the owner of served file directory. 

### Nginx CORS 
Allow `http(s)://47.92.6.114:8000` or `http(s)://www.my-cn.com` or `http(s)://my-cn.com` to access this domain using `GET`/`POST`/`OPTIONS` methods.

1. write next stuff into `/etc/nginx/cros-my-cn.com`
```bash
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
    if ($request_method = 'POST') {
        set $cors "${cors}post";
    }

    if ($cors = "true") { # exact matching
        # Catch all incase there's a request method we're not dealing with properly
        add_header 'Access-Control-Allow-Origin' "$http_origin";
    }
    # this section can't be merged with next section
    if ($cors ~* "trueoptions") {  # case-insensitive regex matching
        add_header 'Access-Control-Allow-Origin' "$http_origin";
        # you may need other headers that allowed
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
    if ($cors = "truepost") { 
        add_header 'Access-Control-Allow-Origin' "$http_origin";
        add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    }
```
2. include that file into anywhere you want. 
```bash
location /api/submissions/ {
    include /etc/nginx/cros-my-cn.com;
}
```
3. test cross-domain using telent for http site.
```bash
$ ✗ telnet my.com 80
Trying 104.27.160.90...
Connected to my.com.
Escape character is '^]'.
GET / HTTP/1.1
Host: my.com
Origin: https://my-cn.com

HTTP/1.1 301 Moved Permanently
Date: Wed, 13 Jun 2018 02:13:25 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Set-Cookie: __cfduid=d01fd125e961f6f6a85437e2a6eac7f901528856005; expires=Thu, 13-Jun-19 02:13:25 GMT; path=/; domain=.my.com; HttpOnly
Location: https://my.com/
X-Content-Type-Options: nosniff
Server: cloudflare
CF-RAY: 42a109a8c6c09ec9-ORD
```
4. test cross-domain using openssl for https site.  `openssl s_client -quiet -connect my.com:443 `
```bash
$ openssl s_client -quiet -connect my.com:443 
depth=2 C = US, O = GeoTrust Inc., CN = GeoTrust Global CA
verify return:1
depth=1 C = US, O = GeoTrust Inc., CN = RapidSSL SHA256 CA
verify return:1
depth=0 CN = www.my.com
verify error:num=10:certificate has expired
notAfter=Jun  7 23:59:59 2018 GMT
verify return:1
depth=0 CN = www.my.com
notAfter=Jun  7 23:59:59 2018 GMT
verify return:1 
# request start from here
GET / HTTP/1.1
Host: my.com
Origin: https://my-cn.com

HTTP/1.1 200 OK
Server: nginx
Date: Wed, 13 Jun 2018 02:15:01 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 28095
Connection: keep-alive
Vary: Accept-Encoding
X-Frame-Options: SAMEORIGIN
Vary: Cookie
Set-Cookie: csrftoken=98a9ZOlwms3AQ2MKeKy9gX7VFMnAfUcf8UkR6BQWkbesTHFAg2C276xAq50ZzEbF; expires=Wed, 12-Jun-2019 02:15:01 GMT; Max-Age=31449600; Path=/; Secure
Access-Control-Allow-Origin: https://my-cn.com
Access-Control-Allow-Headers: Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With,X-CSRFToken
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET,POST,OPTIONS

<!DOCTYPE html>


<html>
  <head>
......
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
With Address Location
```bash
root@xxxxx:~# FILE=chrome.log; IFS=$'\n' ;echo -e "ReqCount \t IP \t\t Org"; for i in `cat $FILE | awk '{print $1}' | sort | uniq -c |sort -k1n | tail -20`; do IP=`echo $i|awk '{print $2}'`; echo -n -e `echo $i|awk '{print $1, "\t"}'`; echo -n -e "$IP \t\t"; curl -s ipinfo.io/$IP|jq '.org'; done
ReqCount 	 IP 		 Org
1838 	218.199.26.80 		"AS4538 China Education and Research Network Center"
2044 	2601:547:980:2e31:c07d:649e:5d03:12f6 		"AS7922 Comcast Cable Communications, LLC"
2047 	116.66.184.189 		"AS131444 HUAWEI INTERNATIONAL PTE. LTD."
2057 	2601:140:8780:a12:346c:4825:f74c:ed45 		"AS7922 Comcast Cable Communications, LLC"
2161 	72.79.47.248 		"AS701 MCI Communications Services, Inc. d/b/a Verizon Business"
2311 	2601:646:c004:9df0:f992:f9f0:358:cf97 		"AS7922 Comcast Cable Communications, LLC"
2349 	108.5.255.156 		"AS701 MCI Communications Services, Inc. d/b/a Verizon Business"
2387 	54.240.198.33 		"AS16509 Amazon.com, Inc."
2474 	2.152.14.227 		"AS12357 VODAFONE ESPANA S.A.U."
2665 	2606:a000:4e07:a400:7c3f:2801:faa5:f63d 		"AS11426 Time Warner Cable Internet LLC"
2861 	173.239.228.55 		"AS20473 Choopa, LLC"
3068 	204.4.182.16 		"AS33598 The Goldman Sachs Group, Inc."
3311 	108.21.236.44 		"AS701 MCI Communications Services, Inc. d/b/a Verizon Business"
3409 	206.47.221.212 		"AS577 Bell Canada"
3623 	128.8.120.3 		"AS27 University of Maryland"
3827 	96.224.219.154 		"AS701 MCI Communications Services, Inc. d/b/a Verizon Business"
3862 	73.231.17.62 		"AS7922 Comcast Cable Communications, LLC"
4144 	2601:647:4b00:f070:b4a6:ad61:6a26:57f 		"AS7922 Comcast Cable Communications, LLC"
4394 	2601:600:9780:1580:a5d8:493f:5827:69de 		"AS7922 Comcast Cable Communications, LLC"
4396 	2601:646:c101:b81e:e480:5c8b:caff:7f01 		"AS7922 Comcast Cable Communications, LLC"
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
