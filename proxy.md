# ngrok usage
we can use next script to generate certs and start client/server,

NOTE: ngrok 1.x stopped development, a better forked version would be https://github.com/morganwu277/pgrok 
```sh
#!/bin/sh

# we have to use openssl from Cellar, since it does have -addext option
alias openssl=/usr/local/Cellar/openssl@1.1/1.1.1l/bin/openssl

export NGROK_DOMAIN="proxy.local"
export IP="10.5.5.5" # public IP Address of proxy.local

function gen_certs() {
	set -xe
	openssl genrsa -out rootCA.key 2048
	openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -addext "subjectAltName=IP:${IP}" -days 5000 -out rootCA.pem
	openssl genrsa -out device.key 2048
	openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -addext "subjectAltName=IP:${IP}" -out device.csr
	openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000

	\cp rootCA.pem assets/client/tls/ngrokroot.crt
	\cp device.crt assets/server/tls/snakeoil.crt
	\cp device.key assets/server/tls/snakeoil.key
	set +x
}

function release() {
	make release-client
	make release-server
}

function start_client() {
	cd bin
	# put ./ngrok.yml under bin directory, content as next:
# server_addr: "proxy.local:4443"
# trust_host_root_certs: false
# tunnels:
#   tcp1:
#     proto:
#       tcp: 8666				 # local port
#     remote_port: 18666 # then open tcp://proxy.local:18666
	GODEBUG=x509ignoreCN=0 ./ngrok -log stdout --log-level=debug -config ./ngrok.yml start-all
}

function start_server() {
	cd bin
	./ngrokd -domain=$NGROK_DOMAIN -httpAddr=":8000" -httpsAddr=":8001" -log-level=DEBUG
}
```
