1. 如非必要，永远不要对外开放3306等之类的端口，只对本地开放，或者防火墙关闭IP地址访问    

2. 禁止ssh login的列表 http://lists.blocklist.de/lists/ssh.txt  http://www.blocklist.de/en/view.html?ip=116.31.116.51 

    ```bash
    [root@ip-*-*-*-* log]# cat /etc/hosts.deny 
    #
    # hosts.deny	This file contains access rules which are used to
    #		deny connections to network services that either use
    #		the tcp_wrappers library or that have been
    #		started through a tcp_wrappers-enabled xinetd.
    #
    #		The rules in this file can also be set up in
    #		/etc/hosts.allow with a 'deny' option instead.
    #
    #		See 'man 5 hosts_options' and 'man 5 hosts_access'
    #		for information on rule syntax.
    #		See 'man tcpd' for information on tcp_wrappers
    #
    sshd: /etc/hosts_ssh.deny  #内容是上述ssh.txt的结果
    ```
