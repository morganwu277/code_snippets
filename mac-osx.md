## virt-manager on Mac OSX
```
brew tap jeffreywildman/homebrew-virt-manager
brew install virt-manager virt-viewer
```
## get LISTEN connections
```
lsof -n -i4TCP:$PORT | grep LISTEN
```
## modify IntelliJ java version
```
[12:15 PM morganwu@morgan-yinnut Contents]$ grep -a1 'JVMVersion' /Applications/IntelliJ\ IDEA\ 14.app/Contents/Info.plist 

      <key>JVMVersion</key>
      <string>1.8*</string> // modify  this to be 1.8* or 1.6+ or any version you want
```
