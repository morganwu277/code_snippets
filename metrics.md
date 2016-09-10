### Collect metrics of DISK and MEM
```bash
#!/bin/bash

metric_name="disk_ratio"
metric_type="float"
metric_value=`df --total | tail -1 | awk '{ printf "%.2f\n", $3/($3+$4) }'`
gmetric --name=$metric_name --value=$metric_value --type=$metric_type --group="disk"


metric_name="disk_used"
metric_type="float"
metric_value=`df --total | tail -1 | awk '{ printf "%.2f\n", $3 }'`
gmetric --name=$metric_name --value=$metric_value --type=$metric_type --group="disk"


metric_name="mem_ratio"
metric_type="float"
MEM_TOTAL=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
MEM_FREE=`cat /proc/meminfo | grep MemFree | awk '{print $2}'`
MEM_CACHE=`cat /proc/meminfo | grep ^Cached | awk '{print $2}'`
let "MEM_USED = MEM_TOTAL - MEM_FREE - MEM_CACHE"
metric_value=`echo $MEM_USED/$MEM_TOTAL | bc -l`
gmetric --name=$metric_name --value=$metric_value --type=$metric_type --group="memory"


metric_name="mem_used"
metric_type="float"
MEM_TOTAL=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
MEM_FREE=`cat /proc/meminfo | grep MemFree | awk '{print $2}'`
MEM_CACHE=`cat /proc/meminfo | grep ^Cached | awk '{print $2}'`
let "MEM_USED = MEM_TOTAL - MEM_FREE - MEM_CACHE"
metric_value=`echo $MEM_USED | bc -l`
gmetric --name=$metric_name --value=$metric_value --type=$metric_type --group="memory"


metric_name="used_swap"
metric_type="float"
SWAP_TOTAL=`cat /proc/meminfo | grep SwapTotal | awk '{print $2}'`
SWAP_FREE=`cat /proc/meminfo | grep SwapFree | awk '{print $2}'`
let "SWAP_USED = SWAP_TOTAL - SWAP_FREE"
metric_value=$SWAP_USED
gmetric --name=$metric_name --value=$metric_value --type=$metric_type --group="memory" --units="Kilobytes"

```
