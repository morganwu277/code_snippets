## network connections
```bash
ss -l # view listening ports
```

## debian china fast mirror
```bash
curl http://mirrors.163.com/.help/sources.list.jessie 
# will download next, please put into /etc/apt/sources.list and use `apt-get update`
deb http://mirrors.163.com/debian/ jessie main non-free contrib
deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib
deb http://mirrors.163.com/debian/ jessie-backports main non-free contrib
deb-src http://mirrors.163.com/debian/ jessie main non-free contrib
deb-src http://mirrors.163.com/debian/ jessie-updates main non-free contrib
deb-src http://mirrors.163.com/debian/ jessie-backports main non-free contrib
deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib
deb-src http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib
```

## install nslookup
no nslookup for default install.
```bash
root@fluentd-elasticsearch-centos7-node-224:/$ apt-get update
root@fluentd-elasticsearch-centos7-node-224:/$ apt-cache search nslookup
knot-dnsutils - Clients provided with Knot DNS (kdig, knslookup, knsupdate)
libnet-nslookup-perl - simple DNS lookup module for perl
root@fluentd-elasticsearch-centos7-node-224:/$ apt-get install dnsutils
```

## [Ubuntu] auto start service

```bash
$ sudo update-rc.d <service_name> defaults
```
or 
```bash
$ update-rc.d <service_name> enable 
```
## [Ubuntu] start with daemon, but keep the log.
```bash
start-stop-daemon --start --background --quiet -u wpleetcode -g wpleetcode  --exec /usr/local/bin/uwsgi --  --ini /home/wpleetcode/leetcode.com/noj_uwsgi.ini
start-stop-daemon --start --quiet --background --pidfile ~/leetcode.com/noj_uwsgi.pid --exec /home/wpleetcode/virtualenvs/noj/bin/uwsgi -- --ini  /home/wpleetcode/leetcode.com/noj_uwsgi.ini

```
