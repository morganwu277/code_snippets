
# ansible vault

Ref: https://docs.ansible.com/ansible/latest/user_guide/vault.html

To use vault, we have several steps (these are for embedded usage steps):

0. (optional) after you install ansible, you should already have `ansible-vault`

1. create a encryped password file
```bash
echo 'YOUR_PASS' > .ansible_dev_pwds
```
And then put `vault_password_file = .ansible_dev_pwds` under `[defaults]` section in your ansible project conf file `ansible.cfg`. eg.
```
[defaults]
vault_password_file = .ansible_dev_pwds
host_key_checking = false
inventory = .hosts
```

2. encrypt any sensitive string, eg. to encrypt `123456_is_my_password`, we execute
```bash
(py3) ➜  ansible-playbooks git:(master) ansible-vault encrypt_string '123456_is_my_password' --name api_key
api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          64636434656337623432616333326135396230323262663533613233656661613930653064383862
          6163346564353931643461633731353435633665316434320a626634333062616464323662323237
          30383366303935383039636232323930616534626635363962333837623635316265346163326230
          6339613236383966630a643934386638373162326634333963343235323834366337393166393830
          32623534383062313635333161626334636436326565303137323537323735646661
Encryption successful
```

NOTE: if we didn't put `vault_password_file` config in above `ansible.cfg`, we need manually set this argument
`ansible-vault encrypt_string --vault-password-file .ansible_dev_pwds '123456_is_my_password' --name api_key`

3. replace the values into your variable in your playbook's vars.yml
eg. 
```yaml
api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          65613839636532666363643765336339356337353731366330373438353339343565623232626331
          3936323035613935316234386666306334346137623136300a333236373732383233643937353032
          64353939393033323338346464396637363934633636666337316530663531393666643265616466
          6135366635356136380a356230346562373365663064383935363331373233633438303833656632
          62376265343466336530626463383538376339326433643961343239383338333866613766303034
          6332333664386135626361333064346133356436396361626264
```

4. The way to decrypt above encoded result is to use `debug` module
```bash
ansible my_server -m debug -a 'var=api_key'
```

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

# access webservice and manipulate json result and register vars and conditions

Access webservice and then manipulate json result and monitor result
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

# more ansible notes
https://www.cnblogs.com/kevingrace/category/924510.html