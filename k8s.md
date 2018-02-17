## add scheduler policy 
Ref: https://github.com/kubernetes/kubernetes/blob/release-1.5/docs/devel/scheduler.md 
Use the `LeastRequestedPriority` .
add `--policy-config-file=/etc/kubernetes/policy-config.json  --use-legacy-policy-config=true` to scheduler start options. 

```json
{
    "kind" : "Policy",
    "apiVersion" : "v1",
    "predicates" : [
        {"name" : "PodFitsPorts"},
        {"name" : "PodFitsResources"},
        {"name" : "NoDiskConflict"},
        {"name" : "MatchNodeSelector"},
        {"name" : "HostName"}
     ],
    "priorities" : [
        {"name" : "LeastRequestedPriority", "weight" : 100000},
        {"name" : "BalancedResourceAllocation", "weight" : 1},
        {"name" : "ServiceSpreadingPriority", "weight" : 1},
        {"name" : "EqualPriority", "weight" : 1}
     ]
}
```


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
