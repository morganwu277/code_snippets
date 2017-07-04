## use `ps` to see the threads inside some process

`-L: show thread`

```bash
[m92wu@ecelinux3 ~]$ ps -efL | grep out
m92wu     6684  6482  6684  0    3 15:38 pts/2    00:00:00 ./a.out 1 1
m92wu     6684  6482  6685  0    3 15:38 pts/2    00:00:00 ./a.out 1 1
m92wu     6684  6482  6686  0    3 15:38 pts/2    00:00:00 ./a.out 1 1
m92wu     6734  6691  6734  0    1 15:38 pts/3    00:00:00 grep --color=auto out
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
This line executes the `ping` and the `ls` command **every 12am and 12pm on the 1st day of every 2nd month**. 
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
```bash
$ echo $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
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

## firewall-cmd uses
```bash
firewall-cmd --zone=public --add-port=5060-5061/udp --permanent
```
add `5060-5061/udp` to white list of `public` zone and make `--permanent`, you need restart firewalld service. 
