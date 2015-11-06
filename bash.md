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
# grep 1415714880.156:29 /var/log/audit/audit.log | audit2why
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
