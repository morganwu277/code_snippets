
# relabel config
https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config

Next is the `ServiceMonitor` metricRelabelings config, https://github.com/prometheus-operator/prometheus-operator/issues/1604#issue-340067180 

next sample complete 3 tasks before last step to write a metric sample data entry :
1. add a new label `pool_name`, extracted from $2 part of regex
2. add a new label `attribute`, extracted from $3 part of regex
3. change the metric name `__name__` meta label

NOTE: only regex matched metric samples will be changed.
```
      metricRelabelings:
        - action: replace
          regex: (com_ps_he_tpool)_(.+)_(active|max|pct|queue_capacity|queue_size)
          replacement: '${2}'
          sourceLabels:
            - __name__
          targetLabel: pool_name
        - action: replace
          regex: (com_ps_he_tpool)_(.+)_(active|max|pct|queue_capacity|queue_size)
          replacement: '${3}'
          sourceLabels:
            - __name__
          targetLabel: attribute
        # NOTE: ! this line must be the last one, since this one changed the name
        - action: replace
          regex: (com_ps_he_tpool)_(.+)_(active|max|pct|queue_capacity|queue_size)
          replacement: com_ps_he_tpool
          sourceLabels:
            - __name__
          targetLabel: __name__
```

it turns
```
com_ps_he_tpool_app_pool_active{container="sw-auth",xxxxxx,xxxxx}

```
into
```
com_ps_he_tpool{attribute="active",pool_name="app_pool",container="sw-auth",xxxxxx,xxxxx}
```

