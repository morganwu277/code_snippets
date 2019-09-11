
## Save server certificafte
Using openssl command to save server certificate

```bash
HOST="private-docker.xxx.com"

echo QUIT | openssl s_client -showcerts -connect $HOST:443 -servername $HOST 2>/dev/null | openssl x509 -text > '/etc/docker/certs.d/$HOST:443/ca.crt'
```

