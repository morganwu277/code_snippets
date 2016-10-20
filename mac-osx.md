## use `ps` to see the threads inside some process

```bash
[02:32 PM morganwu@v1020-wn-185-212 producer]$ ps -Mfc -p 3066 
USER       PID   TT   %CPU STAT PRI     STIME     UTIME COMMAND   UID  PPID   C STIME   TTY           TIME
morganwu  3066 s001    0.0 S    31T   0:00.00   0:00.00 thread    501  2757   0  2:30PM ttys001    0:00.00
          3066         0.0 S    31T   0:00.00   0:00.00           501  2757   0  2:30PM ttys001    0:00.00
          3066         0.0 S    31T   0:00.00   0:00.00           501  2757   0  2:30PM ttys001    0:00.00

```


## virt-manager on Mac OSX
```
brew tap jeffreywildman/homebrew-virt-manager
brew install virt-manager virt-viewer
```
## lsof connections
```bash
lsof -n -i4TCP:$PORT | grep LISTEN
lsof -P -iTCP # 显示端口
netstat -nat |grep LISTEN
lsof -n -P -i TCP -s TCP:LISTEN
```
## modify IntelliJ java version
```
[12:15 PM morganwu@morgan-yinnut Contents]$ grep -a1 'JVMVersion' /Applications/IntelliJ\ IDEA\ 14.app/Contents/Info.plist 

      <key>JVMVersion</key>
      <string>1.8*</string> // modify  this to be 1.8* or 1.6+ or any version you want
```

## install sshpass on Mac-OSX
```
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```
> reference: [Installing SSHPass](https://gist.github.com/arunoda/7790979)

## crontab location
**/usr/lib/cron/tabs/morganwu**

## change display langeuage of Chrome under OSX
```bash
defaults write com.google.Chrome AppleLanguages '(zh-CN)'
```
## list routing talbe
```bash
$ netstat -r
```
