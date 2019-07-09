## init containers with mountpath
Two notes:
1. initContainer section
2. mount path
3. command, how to write script content 
```
controller:
  stats: # so that we open port 18080
    enabled: true
  kind: "DaemonSet"
  service:
    type: NodePort
    nodePorts:
      http: 80
      https: 443
  extraInitContainers:
  - name: init-nginx
    image: busybox
    # use a complex path, so this won't be hacked by simple guess
    command:
    - /bin/bash
    - -c
    - >
      set -e;
      set -x;
      cd /etc/nginx/noj
      wget -c https://s3-us-west-1.amazonaws.com/xxx_bucket_xxx/nginx/mappings-9af6c3ea-372a-4480-92bc-fdc5584a58c2.tar.gz
      rm -f mappings-*.tar.gz
      tar xvf mappings-*.tar.gz
      echo "working directory: `pwd`"
    volumeMounts:
    - mountPath: /etc/nginx/noj
      name: nginx-data
  extraVolumes:
  - name: nginx-data
    emptyDir: {}
  extraVolumeMounts:
    - mountPath: /etc/nginx/noj
      name: nginx-data
  # configMap, by default the configmap already include a data section, we just need to specify the key-value pair...
  # https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap
  config:
    http-snippet: |
      map $request_uri $new_uri {
          include /etc/nginx/xxx/mappings/nginx_mapping.map;
          include /etc/nginx/xxx/mappings/nginx_mapping_in.map;
      }

```
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

## Pods Amount goes up to 2500, need increase ARP cache
https://mp.weixin.qq.com/s/37v5TqYIRNg9pje725kewg 
increase ARP cache in `/etc/sysctl.conf`, or ARP cache will be used up and slow down the ARP requests.
```
net.ipv4.neigh.default.gc_thresh1 = 80000
net.ipv4.neigh.default.gc_thresh2 = 90000
net.ipv4.neigh.default.gc_thresh3 = 100000
```

## nginx ingress template
Another reference that we can use to proxy traffic to external server: https://www.elvinefendi.com/2018/08/08/ingress-nginx-proxypass-to-external-upstream.html 
```
{% if INGRESS_SSL == 'none' %}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-{{ APP_NAME }}-ingress
  namespace: {{ CLUSTER }}
  annotations:
    nginx.ingress.kubernetes.io/upstream-max-fails: "3"
    nginx.ingress.kubernetes.io/upstream-fail-timeout: "30"
{% if COOKIE_SESSION == 'true' %}
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "route"
    nginx.ingress.kubernetes.io/session-cookie-hash: "sha1"
{% endif %}
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    nginx.ingress.kubernetes.io/configuration-snippet: |
          error_page 404 500 502 503 504     /;
spec:
  rules:
  - host: "{{ SERVER_HOST }}"
    http:
      paths:
      - backend:
          serviceName: "{{ SVC_NAME }}"
          servicePort: 8080
        path: {{ APP_CONTEXT_PATH }}
{% endif %}
{% if INGRESS_SSL != 'none' %}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-{{ APP_NAME }}-ssl-ingress
  namespace: {{ CLUSTER }}
  annotations:
    nginx.ingress.kubernetes.io/upstream-max-fails: "3"
    nginx.ingress.kubernetes.io/upstream-fail-timeout: "30"
{% if COOKIE_SESSION == 'true' %}
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "route"
    nginx.ingress.kubernetes.io/session-cookie-hash: "sha1"
{% endif %}
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
{% if INGRESS_SSL != 'none' %}
    nginx.ingress.kubernetes.io/auth-tls-secret: "{{ CLUSTER }}/{{ CA_SECRET_NAME }}"
    nginx.ingress.kubernetes.io/auth-tls-verify-depth: "3"
  {% if INGRESS_SSL == '2way' %}
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
  {% else %}
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "off"
  {% endif %}
{% endif %}
{% if JVM_SSL != 'none' %}
    nginx.ingress.kubernetes.io/secure-backends: "true"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      error_page 404 500 502 503 504     /;
      proxy_ssl_certificate         /ingress-controller/ssl/{{ CLUSTER }}-{{ SERVER_CRT_SECRET_NAME }}.pem;
      proxy_ssl_certificate_key     /ingress-controller/ssl/{{ CLUSTER }}-{{ SERVER_CRT_SECRET_NAME }}.pem;
      proxy_ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;
      proxy_ssl_ciphers             HIGH:!aNULL:!MD5;
      proxy_ssl_trusted_certificate /ingress-controller/ssl/ca-{{ CLUSTER }}-{{ CA_SECRET_NAME }}.pem;
    {% if JVM_SSL == '2way' %}
      proxy_ssl_verify        on;
    {% else %}
      proxy_ssl_verify        off;
    {% endif %}
      proxy_ssl_verify_depth  3;
      proxy_ssl_session_reuse on;
{% endif %}
spec:
  tls:
  - hosts:
    - "{{ TLS_SERVER_HOST }}"
    secretName: "{{ SERVER_CRT_SECRET_NAME }}"
  rules:
  - host: "{{ TLS_SERVER_HOST }}"
    http:
      paths:
      - backend:
          serviceName: {{ SVC_NAME }}
{% if JVM_SSL != 'none' %}
          servicePort: 8443
{% endif %}
{% if JVM_SSL == 'none' %}
          servicePort: 8080
{% endif %}
        path: {{ APP_CONTEXT_PATH }}

{% endif %}
```
