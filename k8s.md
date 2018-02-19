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

If you want some nodes to be more aggressive on the Pod distrubution, which means, put more Pods as much as it can on one Node. You can use next policy:
```json
{
    "kind" : "Policy",
    "apiVersion" : "v1",
    "predicates" : [
      {"name" : "GeneralPredicates"},
      {"name" : "MatchInterPodAffinity"},
      {"name" : "NoDiskConflict"},
      {"name" : "NoVolumeZoneConflict"},
      {"name" : "PodToleratesNodeTaints"}
    ],
    "priorities" : [
      {"name" : "MostRequestedPriority", "weight" : 1},
      {"name" : "InterPodAffinityPriority", "weight" : 2}
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

## Pod Anti Affinity
Put those kube-dns on different Nodes
```yml
affinity:
 podAntiAffinity:
   requiredDuringSchedulingIgnoredDuringExecution:
   - weight: 100
     labelSelector:
       matchExpressions:
       - key: k8s-app
         operator: In
         values:
         - kube-dns
     topologyKey: kubernetes.io/hostname
```

## Pods Amount goes up to 2500
increase ARP cache in `/etc/sysctl.conf`, or ARP cache will be used up and slow down the ARP requests.
```
net.ipv4.neigh.default.gc_thresh1 = 80000
net.ipv4.neigh.default.gc_thresh2 = 90000
net.ipv4.neigh.default.gc_thresh3 = 100000
```
