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
rsync --progress -avz --delete-excluded="*node_modules*" --include='.*' update/dist/* dist/
```
We sync all files from `update/dist` directory to `dist` directory, including those hidden files from source directory. But we won't delete the files with "*node_modules*" pattern if target directory already exist while source directory doesn't contains.

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
http://www.howtogeek.com/114812/5-cool-things-you-can-do-with-an-ssh-server/ 

## ssh generate pub key from existing private key
```bash
$ ssh-keygen -f private_key -y
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
