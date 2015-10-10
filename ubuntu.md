## install nslookup
no nslookup for default install.
```bash
root@fluentd-elasticsearch-centos7-node-224:/$ apt-get update
root@fluentd-elasticsearch-centos7-node-224:/$ apt-cache search nslookup
knot-dnsutils - Clients provided with Knot DNS (kdig, knslookup, knsupdate)
libnet-nslookup-perl - simple DNS lookup module for perl
root@fluentd-elasticsearch-centos7-node-224:/$ apt-get install dnsutils
```
