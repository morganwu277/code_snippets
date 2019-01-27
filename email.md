# send email using mutt
1. install mutt
```bash
apt-get install mutt sasl2-bin ca-certificates
```
or 
```bash
yum install mutt cyrus-sasl-plain ca-certificates
```
or 
```bash
brew install mutt
```

2. configure `~/.muttrc` config
```bash
set from = "<gmail-id>@gmail.com"
set realname = "Dan Nanni"
set smtp_url = "smtp://<gmail-id>@smtp.gmail.com:587/"
set smtp_pass = "<gmail-password>"
```
you may need Gmail App password https://support.google.com/accounts/answer/185833?hl=en 

if you do have Exchange server, next is another example:
```bash
set from = "xxx@company.com"
set realname = "System Check"
set smtp_url = "smtp://xxx@company.com@smtp.office365.com:587/"
set smtp_pass = "ThisIsMyPassword"
```

3. Send out the email
```bash
cat server_status.txt | mutt -s “VM is down, please help to boot up”  user1@company.com,user2@company.com -c myself@company.com -c myManager@company.com
```

# inotify watch and send emails
```bash
#!/bin/bash

# default of space, tab and nl
unset IFS

LOG_BASE_PATH="${1-/home/morganwu/htap-ng_master/htap-ng/db2root/buildlog/}"
echo "Start watching files under $LOG_BASE_PATH"
# Wait for filesystem events
inotifywait -m ${LOG_BASE_PATH} |
while read dir event file ;
do
  path="${LOG_BASE_PATH}/${file}"
  if [[ ! -f "$path" ]]; then
    continue
  fi
  output=`tail -2 "$path" | head -1`
  if [[ "$output" == "*** Build Output saved to" ]]; then
    # send email notification, for email setup, see next:
    echo "[`date`] Build DONE!"
    echo "[`date`] Build DONE!" | mutt -s "Buid is Done!" xue777hua@gmail.com
    exit 0
  elif [[ "$event" == "MODIFY" ]]; then
    echo "[`date`] $dir $event $file"
  fi
done

```
