# debug & stoppable

1. Stop using `fail` module:
```yaml
- name: "STOP ME"
  fail: msg="This is the debugging stop"
  when: 1==1
```

2. Print host information

Mainly use `debug` to print message.

`with_items` is also being used as loop here.

```yaml
- debug:
    msg: "hosts mapping is: {{ hostvars[item]['ansible_eth1'].ipv4.address }} {{item}}"
  with_items: "{{ groups['machines'] }}" # machines is the host group name in the inventory
```
NOTE: for above `['ansible_eth1'].ipv4.address` we need to setup `gather_facts: true` before running above task.

3. Manipulate the json response then print based on different conditions
```yaml
- hosts: all
  gather_facts: false
  tasks:
    - name: Get OS Version
      become: true
      shell: "echo `cat /etc/os-release | grep PRETTY_NAME`"
      register: res
    - debug:
        msg: "{{ res.stdout }}" # we have to add double quote here
```

4. Access webservice and then manipulate json result and monitor result
```yaml
---

# with this action it should return the status of the application “rbcapp1” and a list of services
#  that are down. (you can use the REST endpoint created in TEST1).

- name: Check Service Status
  hosts: 127.0.0.1
  connection: local
  gather_facts: False
  tasks:
    - name: Check service status from {{ health_check_url }} endpoint
      uri:
        url: "{{ health_check_url }}"
        return_content: yes
      register: health_check_res
    # samle json response:
    # {
    #   "result": "ok",
    #   "services": {
    #     "httpd": "UP",
    #     "postgresql": "DOWN",
    #     "rabbitmq": "UP"
    #   },
    #   "status": "DOWN"
    # }
    - set_fact:
        bad_svc: {}
    # the most import part is here that we need to extract all DOWN service ONLY
    - set_fact:
        bad_svc: "{{bad_svc |combine({item.key: item.value})}}" # 3. append to bad_svc dict
      when: "{{item.value in ['DOWN']}}" # 2. in the loop when service is down
      with_dict: "{{health_check_res.json.services}}" # 1. loop over services

    - name: Congrats, all services are in good status
      debug:
        msg: "All services are in good status: {{ health_check_res.json.status }} "
      when: health_check_res.json.status == "UP"

    - name: Alert, we have bad service status
      debug:
        msg: "Bad service status! {{ bad_svc }} " # 4. print the constructed bad_svc dict above
      when: health_check_res.json.status == "DOWN"
      failed_when: health_check_res.json.status == "DOWN"
```