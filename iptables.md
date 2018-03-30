## clear all rules
https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules 

```bash
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
```

and then 
```bash
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
```

## restrict ip access
```bash
iptables -I INPUT -s 58.213.108.0/24 -j DROP
```
Use `-D` to delete this rule.
