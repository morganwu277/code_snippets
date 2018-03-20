# send email using mutt
1. install mutt
```bash
apt-get install mutt sasl2-bin 
```
or 
```bash
yum install mutt cyrus-sasl-plain
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

