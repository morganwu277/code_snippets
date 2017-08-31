## Let `kubectl` command on node to access cluster resources
```bash
alias kubectl='kubectl --kubeconfig=/etc/kubernetes/kubelet.kubeconfig'
```
## kube logrotate

```bash
clove@kubernetes-master /etc/logrotate.d $ cat *
/var/lib/docker/containers/*/*-json.log {
    rotate 5
    copytruncate
    missingok
    notifempty
    compress
    maxsize 10M
    daily
    create 0644 root root
}
/var/log/kube-addons.log {
    rotate 5
    copytruncate
    missingok
    notifempty
    compress
    maxsize 100M
    daily
    create 0644 root root
}
/var/log/kube-apiserver.log {
    rotate 5
    copytruncate
    missingok
    notifempty
    compress
    maxsize 100M
    daily
    create 0644 root root
}
/var/log/kube-controller-manager.log {
    rotate 5
    copytruncate
    missingok
    notifempty
    compress
    maxsize 100M
    daily
    create 0644 root root
}
/var/log/kube-proxy.log {
    rotate 5
    copytruncate
    missingok
    notifempty
    compress
    maxsize 100M
    daily
    create 0644 root root
}
/var/log/kube-scheduler.log {
    rotate 5
    copytruncate
    missingok
    notifempty
    compress
    maxsize 100M
    daily
    create 0644 root root
}
```
