## virt-manager on Mac OSX
```
brew tap jeffreywildman/homebrew-virt-manager
brew install virt-manager virt-viewer
```
## lsof connections
```bash
lsof -n -i4TCP:$PORT | grep LISTEN
lsof -P -iTCP # 显示端口
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
