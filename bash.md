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
## list installed/uninstalled rpm content( or to know what will be influenced after installation or uninstallation)
```bash
# for uninstalled rpm ( there should be a package.rpm file in the current directory)
[root@kube0 ~]$ rpm -qlp package.rpm (query list of package)
# for installed rpm (eg. get the name from `rpm -qa|grep ${name}` )
[root@kube0 ~]$ rpm -ql package (query list of package) 
```

