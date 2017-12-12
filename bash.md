## reserved space for root user in Linux
```bash
tune2fs -m 5 /dev/sda 
```
## json string extraction inside the bash
Python 2: 
```bash
export PYTHONIOENCODING=utf8
curl -s 'https://api.github.com/users/lambda' | \
    python -c "import sys, json; print json.load(sys.stdin)['name']"
```
Python 3: 
```bash
curl -s 'https://api.github.com/users/lambda' | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['name'])"
```

## master election inside the BASH
```bash
ETCD_SERVER=$ETCD_SERVER
ETCD_URL_PREFIX="http://$ETCD_SERVER:2379/v2/keys"
APPLICATION="noj"
MASTER_NODE=false

function master_election() {
    [[ $ETCD_SERVER == "" ]] && echo "[ERROR]: can not find etcd server, master election failed. " && exit 1
    # write the key
    this_host=`hostname`
    echo "[DEBUG]: write current hostname $this_host to $ETCD_URL_PREFIX/$APPLICATION_deploy ..."
    curl "$ETCD_URL_PREFIX/$APPLICATION_deploy" -XPOST -d value=$this_host
    first_host=$(curl -s "$ETCD_URL_PREFIX/$APPLICATION_deploy?recursive=true&sorted=true" | python -c "import sys, json; print json.load(sys.stdin)['node']['nodes'][0]['value']" )
    echo "[DEBUG]: got the first_host is $first_host under $ETCD_URL_PREFIX/$APPLICATION_deploy ..."
    [[ "$first_host" == "$this_host" ]] && MASTER_NODE=true
}

function delete_master_election_nodes() {
    echo "[DEBUG]: complete deployment, delete the master election nodes $ETCD_URL_PREFIX/$APPLICATION_deploy"
    curl "$ETCD_URL_PREFIX/$APPLICATION_deploy?recursive=true" -XDELETE
}
```

## capture the time output
```bash
[12:13 AM morganwu@morgan-yinnut ~]$ { time sleep 1 ; } 2> time.txt
[12:13 AM morganwu@morgan-yinnut ~]$ cat time.txt 

real	0m1.010s
user	0m0.001s
sys	0m0.002s

```
## use `ps` to see the threads inside some process

`-L: show thread`

```bash
[m92wu@ecelinux3 ~]$ ps -efL | grep out
m92wu     6684  6482  6684  0    3 15:38 pts/2    00:00:00 ./a.out 1 1
m92wu     6684  6482  6685  0    3 15:38 pts/2    00:00:00 ./a.out 1 1
m92wu     6684  6482  6686  0    3 15:38 pts/2    00:00:00 ./a.out 1 1
m92wu     6734  6691  6734  0    1 15:38 pts/3    00:00:00 grep --color=auto out
```

## IFS using \n
```bash
IFS=$'\n'; for i in `head -n 10 slow.log `;do echo $i ;done;
```
## if conditions 
[what should be put in the if [] ](http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html)

## bash calculator for floating point
```bash
[11:04 PM morganwu@morgan-yinnut producer]$ printf "%.6f\n" `bc -l <<< '100/3'` 
33.333333
[11:04 PM morganwu@morgan-yinnut producer]$ a=`bc -l <<< '100/3'`
[11:04 PM morganwu@morgan-yinnut producer]$ echo $a
33.33333333333333333333

```

## use alias for sudo
set alias sudo='sudo ' to use alias in your sudo command
```
[root@centos7-node-226 ~]# echo "alias sudo='sudo ' " >> ~/.bashrc 
[root@centos7-node-226 ~]# cat .bashrc |grep sudo
alias sudo='sudo ' 
```

## use alias for ssh session command
let alias to be expanded
```
[root@centos7-node-226 ~]# echo "shopt -s expand_aliases" >> ~/.bashrc 
```

## HEX DEC Conversion
```
$ printf %d 0xac
172
$ printf %x 172
ac
```
## debug selinux rule 
```bash
$ grep 1415714880.156:29 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1415714880.156:29): avc:  denied  { name_connect } for  pid=1349 \
  comm="nginx" dest=8080 scontext=unconfined_u:system_r:httpd_t:s0 \
  tcontext=system_u:object_r:http_cache_port_t:s0 tclass=tcp_socket

        Was caused by:
        One of the following booleans was set incorrectly.
        Description:
        Allow httpd to act as a relay

        Allow access by executing:
        # setsebool -P httpd_can_network_relay 1
        Description:
        Allow HTTPD scripts and modules to connect to the network using TCP.

        Allow access by executing:
        # setsebool -P httpd_can_network_connect 1
```
## ssh withouth host confirmation
```bash
scp -o "StrictHostKeyChecking no"
```
## ssh default config
1. without host key checking 
2. keep alive set
```bash
$ cat ~/.ssh/config
Host *
    ServerAliveInterval 240
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
```

## network debug
* `ss -a `
* `netstat -nalp` 
* `lsof -P -i:22`

## GMT+0 standard time
```bash 
[01:58 PM morganwu@morgan-yinnut local]$ date
Sat Dec  5 13:58:52 CST 2015
[01:58 PM morganwu@morgan-yinnut local]$ date -u +%FT%H:%M:%SZ 
2015-12-05T05:58:53Z
```

## zip && unzip
```bash
## view files in zip
$ unzip -l file.zip
## zip all files under a directory
$ zip -r file.zip file_dir
```
## query list of rpm package 
list installed/uninstalled rpm content( or to know what will be influenced after installation or uninstallation)
```bash
# for uninstalled rpm ( there should be a package.rpm file in the current directory)
[root@kube0 ~]$ rpm -qlp package.rpm
# for installed rpm (eg. get the name from `rpm -qa|grep ${name}` )
[root@kube0 ~]$ rpm -ql package  
```
## get gateway IP from bash
```bash
[07:34 PM morganwu@morgan-yinnut start-point]$ curl ifconfig.me
45.62.218.226
```

## operate json from CLI in an easy way
```bash
[09:30 PM morganwu@morgan-yinnut ~]$ curl -s https://api.github.com/users/xue777hua | python -c 'import sys, json; print json.load(sys.stdin)["avatar_url"]'
https://avatars.githubusercontent.com/u/3008959?v=3
```

## curl via socks5 proxy 
```bash
$ curl --socks5 127.0.0.1:9050
```
## rsync files, include, exclude, hidden files
```bash
rsync --progress -avz --delete --recursive --exclude-from=".exclude" . -e 'ssh -p REMOTE_PORT' root@xxx.xxx.xxx.xxx:~
```
We sync all files from current directory to remote machine directory by using ssh protocol with a `REMOTE_PORT` specific port, `.exclude` content is listed as below:  leading + means include, leading - means exclude 
```txt
+ ./*
- .idea/
- .git/
- target/
- input/
- logs/
```

## crontab examples 
Overall Rule: 
```bash
# Minute   Hour   Day of Month       Month          Day of Week        Command    
# (0-59)  (0-23)     (1-31)    (1-12 or Jan-Dec)  (0-6 or Sun-Sat)                
    0        2          12             *                *            /usr/bin/find
```
This line executes the `ping` command **every minute of every hour of every day of every month**. The standard output is redirected to dev null so we will get no e-mail but will allow the standard error to be sent as a e-mail. 
```bash
*       *       *       *       *       /sbin/ping -c 1 192.168.0.1 > /dev/null
```
This line executes the `ping` and the `ls` command **every 12am and 12pm on the 1st day of every 2 month intervaly**. 
```bash
0 0,12 1 */2 * /sbin/ping -c 192.168.0.1; ls -la >>/var/log/cronrun
```
This line executes the disk usage command to get the directory sizes **every 2am on the 1st through the 10th of each month**. E-mail is sent to the email addresses specified with the MAILTO line. The PATH is also set to something different.
```bash
PATH=/usr/local/sbin:/usr/local/bin:/home/user1/bin
MAILTO=user1@nowhere.org,user2@somewhere.org
0 2 1-10 * * du -h --max-depth=1 /
```
This line is and example of running a cron job **every month at 4am on Mondays, and on the days between 15-21**. This is because using the day of month and day of week fields with restrictions (no *) makes this an "or" condition not an "and" condition. Both will be executed.
```bash
0 4 15-21 * 1 /command
```
Run on **every second Sunday of every month**. The test has to be run first because of the issue mentioned in the example above.
```bash
0 4 8-14 * *  test $(date +\%u) -eq 7 && echo "2nd Sunday"
```
## search PDF via `pdfgrep`
could be installed by `brew install pdfgrep` under OSX
```bash
$ find /path -iname '*.pdf' -exec pdfgrep pattern {} +
```

## find files more than 100MB
```bash
$ find . -type f -size +1000000k 
```
## find & grep combination
Delete all files whose name include `bluestack` but path name exclude `Desktop` characters。
```bash
$ sudo find . -iname "*bluestack*" ! -path "*Desktop*" -exec rm -rf {} \;
```
## forward local port 3307 to remote 3306
```bash
$ ssh -p 16688 -L 3307:me-db-1:3306 root@159.203.44.228
```
If we connect to 127.0.0.1:3307 locally, it's like we're connecting me-db-1:3306 by loggin into root@m159.203.44.228 server.
```bash
ssh -p 575 -L 9000:127.0.0.1:20001 xxxx@159.203.238.66
```
This will forward local 9000 port to remote machine 159.203.238.66's 20001 port and 20001 port is listening on 127.0.0.1. 


## ssh by using local port as SOCKS5 proxy
```bash
$ ssh -D 0.0.0.0:9999 -C user@host
```
-D: Dynamic forwarding 
-C: Compress communication
http://www.howtogeek.com/114812/5-cool-things-you-can-do-with-an-ssh-server/ 

## ssh generate pub key from existing private key
```bash
$ ssh-keygen -f private_key -y
```
## ssh hostbased authentication
Write next config for `srv1` server with username/hostname/port/Identity, and even doesn't check the hostname matching.
```bash
Host srv1
    User vagrant
    Port 2222
    Hostname 127.0.0.1
    IdentityFile /Users/morganwu/Developer/workspace/ssh_port_forward/server1/.vagrant/machines/default/virtualbox/private_key
    StrictHostKeyChecking no

```
## write file by using heredoc 
```bash
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```

## CPU benchmark
```bash
time echo "scale=5000; 4*a(1)" | bc -l -q
```

## disk io benchmark
```bash
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75
```

## cygwin basic packages
`curl` `wget` `ssh` `tree` `rsync` `nc`(a simple but powerful tool) `zip` `unzip`(Info-Zip Compression Utilities)

### cygwin terminal color
``` bash 
$ cat ~/.minttyrc
BackgroundColour=13,25,38
ForegroundColour=217,230,242
CursorColour=217,230,242
Black=0,0,0
BoldBlack=38,38,38
Red=184,122,122
BoldRed=219,189,189
Green=122,184,122
BoldGreen=189,219,189
Yellow=184,184,122
BoldYellow=219,219,189
Blue=122,122,184
BoldBlue=189,189,219
Magenta=184,122,184
BoldMagenta=219,189,219
Cyan=122,184,184
BoldCyan=189,219,219
White=217,217,217
BoldWhite=255,255,255
BoldAsFont=-1
FontHeight=9
```

## bash script current working directory
change current working dir to script directory.
```bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
```

## Crontab check a process and retart if dead
```bash
ps -ef | grep jenkins | grep -v grep | grep -v 'su jenkins' || /usr/sbin/service jenkins restart >/tmp/startjenkins.log 2>&1
```
## tcpdump commands
monitor the network flow of 30006 port. 
```bash
[root@node-3-slave-codential wktang]# tcpdump -i eth0 tcp port 30006
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes 
```
for more, please review [tcpdump](https://tldr.ostera.io/tcpdump) and [tcpdump chinese blog](http://www.cnblogs.com/ggjucheng/archive/2012/01/14/2322659.html)

## firewall-cmd/ufw uses
```bash
firewall-cmd --zone=public --add-port=5060-5061/udp --permanent
```
add `5060-5061/udp` to white list of `public` zone and make `--permanent`, you need restart firewalld service. 

```bash
ufw allow proto tcp from 74.207.245.148 to any port 6379
```
This allows tcp from `74.207.245.148` to access this machine `6379` port of any net interface card. 

```bash
root@discuss:~# ufw status |grep '/' | nl
     1	80/tcp                     ALLOW       Anywhere
     2	4567/tcp                   ALLOW       Anywhere
     3	4568/tcp                   ALLOW       Anywhere
     4	4569/tcp                   ALLOW       Anywhere
     5	4570/tcp                   ALLOW       Anywhere
     6	443/tcp                    ALLOW       Anywhere
     7	575/tcp                    ALLOW       Anywhere
     8	8649/udp                   ALLOW       Anywhere
     9	8649/tcp                   ALLOW       Anywhere
    10	80/tcp (v6)                ALLOW       Anywhere (v6)
    11	4567/tcp (v6)              ALLOW       Anywhere (v6)
    12	4568/tcp (v6)              ALLOW       Anywhere (v6)
    13	4569/tcp (v6)              ALLOW       Anywhere (v6)
    14	4570/tcp (v6)              ALLOW       Anywhere (v6)
    15	443/tcp (v6)               ALLOW       Anywhere (v6)
    16	575/tcp (v6)               ALLOW       Anywhere (v6)
    17	8649/udp (v6)              ALLOW       Anywhere (v6)
    18	8649/tcp (v6)              ALLOW       Anywhere (v6)
```
use `nl` to calculate the line number of output, this makes `ufw delete [LINE_NUM]` easier

## `xargs` and apply command to each line
```bash
[root@RHEL7264Bit-7 temp]# find .|grep layer |xargs ls -ltrah
-rw-r--r-- 1 root root  49M Aug 25 12:49 ./e396e1feba70f9da0f880c2fb7719d5e749bf8cfbb6fed02921ed2b78a282c77/layer.tar
-rw-r--r-- 1 root root  53M Aug 25 12:49 ./d642a9532ee6b2288746712db1262d4c5a7ec1bead9d017be9af5efb222896f0/layer.tar
-rw-r--r-- 1 root root 7.5K Aug 25 12:49 ./c6c9f58a01422d043ac79433669d75ac919a11fe118f8d800757614b648e3bdb/layer.tar
-rw-r--r-- 1 root root  16K Aug 25 12:49 ./bd5b778776e7b7078ae7d092d2d4ab7f595c1bdc54039382b56760b1b7db8985/layer.tar
-rw-r--r-- 1 root root 5.5K Aug 25 12:49 ./b55669c9130d2b008064030fbec347810c89ed3c49db993e2890be160c1cf39d/layer.tar
-rw-r--r-- 1 root root  93M Aug 25 12:49 ./a38b6a23ef9916bac242e117d93b671d057053769fc6af0e670fc80e20cb8596/layer.tar
-rw-r--r-- 1 root root 2.5K Aug 25 12:49 ./9e395f45ba84e52f725ce374e64dd7167b4a2d5db0c3a965013c545a3c16ebe9/layer.tar
-rw-r--r-- 1 root root 3.0K Aug 25 12:49 ./693e42990d01db119b677337f7d47388d20692db0b07a0ab8ed05ab62913ecc2/layer.tar
-rw-r--r-- 1 root root 368M Aug 25 12:49 ./5ad685d5a369a7263e35d38eefc68ec60dd723ad8fd3afb1239ade6653631169/layer.tar
-rw-r--r-- 1 root root  27K Aug 25 12:49 ./5481d59c50807917e95aa6e96656405f46db02096b41220d47401033e90d122d/layer.tar
-rw-r--r-- 1 root root  16K Aug 25 12:49 ./4cdeb608206b07a92bdeb3beef88ddbd84ff922cee342bea413be28734ad92fe/layer.tar
-rw-r--r-- 1 root root 3.0K Aug 25 12:49 ./29d31c8f4e579e888d32bfe445b487dcbc72e9416de138718d615f0d4c3663c7/layer.tar
-rw-r--r-- 1 root root 192M Aug 25 12:49 ./1f848715be222b4f94304d00bc5b265a03c1c1253c9e4a980387fa636cd0d76f/layer.tar
-rw-r--r-- 1 root root  16M Aug 25 12:49 ./0b0141ebf39d736914c6858ddc84f6ee3d46371e077ed9ecee2e1e7b2d726e37/layer.tar
```

## output string to stderr
```bash
(>&2 echo "Certificate tls.crt does not exist! Please put it there or generate one!" )
```
## init.d script example
Using this as an template: 
```bash
#! /bin/sh
### BEGIN INIT INFO
# Provides: statsd
# Required-Start: $remote_fs $syslog    
# Required-Stop: $remote_fs $syslog    
# Default-Start: 2 3 4 5    
# Default-Stop: 0 1 6    
# Short-Description: statsd
# Description: This file starts and stops statsd server    
# 
### END INIT INFO    
case "$1" in
    start)
        cd /opt/statsd && nohup /usr/bin/node ./stats.js ./myConfig.js > run.log 2>&1 & 
    ;;
    stop)
        pkill statsd
    ;;
    restart)
        pkill statsd
        cd /opt/statsd && nohup /usr/bin/node ./stats.js ./myConfig.js > run.log 2>&1 &
    ;;
    status)
        ps -ef | grep "statsd" | grep -v grep && exit 0 || exit $?
    ;;
    *)
        echo "Usage: $0 {start|stop|restart}" >&2
        exit 3
    ;;
esac
```
After this, use `systemctl enable statsd` to added it to default level startup, so that it could be controlled by `systemctl`. 
```bash
root@leetcode:/opt/statsd# systemctl enable statsd
statsd.service is not a native service, redirecting to systemd-sysv-install
Executing /lib/systemd/systemd-sysv-install enable statsd
root@leetcode:/opt/statsd# systemctl status statsd
● statsd.service - LSB: statsd
   Loaded: loaded (/etc/init.d/statsd; bad; vendor preset: enabled)
   Active: active (running) since Mon 2017-11-06 22:00:22 PST; 3min 58s ago
     Docs: man:systemd-sysv-generator(8)
   CGroup: /system.slice/statsd.service
           └─13194 statsd ./myConfig.js                  

Nov 06 22:00:22 leetcode.com systemd[1]: Starting LSB: statsd...
Nov 06 22:00:22 leetcode.com systemd[1]: Started LSB: statsd.
```

### create a new disk partition and format the new disk partition
Here is an example of the newly added disk `/dev/sdb`
```bash
# do not change space or newline of this echo 
echo "n \
p




w
q" | fdisk /dev/sdb
mkfs.xfs /dev/sdb1
mkdir -p /mnt/largedisk
mount /dev/sdb1 /mnt/largedisk
echo 'mount /dev/sdb1 /mnt/largedisk' >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
```
