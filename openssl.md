
## Save server certificafte
Using openssl command to save server certificate

```bash
HOST="private-docker.xxx.com"

echo QUIT | openssl s_client -showcerts -connect $HOST:443 -servername $HOST 2>/dev/null | openssl x509 -text > '/etc/docker/certs.d/$HOST:443/ca.crt'
```

## List all available CommonName from ca-certificates.crt
```sh
awk -v cmd='openssl x509 -noout -subject' 
       '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt
```

https://unix.stackexchange.com/a/97252
