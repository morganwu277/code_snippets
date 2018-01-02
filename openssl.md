
## Save server certificafte
Using openssl command to save server certificate

```bash
echo QUIT | openssl s_client -showcerts -connect private-docker.xxx.com:443 -servername private-docker.xxx.com 2>/dev/null | openssl x509 -text > '/etc/docker/certs.d/private-docker.xxx.com:443/ca.crt'
```

